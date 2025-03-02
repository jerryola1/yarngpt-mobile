import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'auth_service.dart';

class UserService {
  static const String _speechCountKey = 'speech_count';
  static const String _lastResetKey = 'last_reset';
  static const int maxDailySpeechCount = 10;
  
  // Flag to disable Firestore operations due to Datastore Mode incompatibility
  static const bool _useFirestore = false;

  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  UserService._({required SharedPreferences prefs}) : _prefs = prefs;

  static Future<UserService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return UserService._(prefs: prefs);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _authService.currentUser != null;
  }

  // Get current user ID
  String? getUserId() {
    return _authService.currentUser?.uid;
  }

  // Register a new user
  Future<void> registerUser({required String name, required String email, String? password}) async {
    try {
      if (password != null) {
        // Register with Firebase Auth
        final userCredential = await _authService.signUp(
          email: email,
          password: password,
          name: name,
        );
        
        // Only attempt Firestore operations if enabled
        if (_useFirestore) {
          try {
            // Try to create user document in Firestore
            await _firestore.collection('users').doc(userCredential.user!.uid).set({
              'name': name,
              'email': email,
              'createdAt': FieldValue.serverTimestamp(),
              'remainingSpeeches': maxDailySpeechCount,
              'lastReset': DateTime.now().millisecondsSinceEpoch,
            });
            print('User document created in Firestore successfully');
          } catch (e) {
            // Log Firestore error but continue with local registration
            print('Error creating Firestore document: $e');
            print('Continuing with local registration only');
          }
        } else {
          print('Firestore operations disabled, using local storage only');
        }
      }
      
      // Always store locally regardless of Firestore success
      await _prefs.setString('user_name', name);
      await _prefs.setString('user_email', email);
      await _prefs.setBool('is_registered', true);
      await _prefs.setInt('remaining_speeches', maxDailySpeechCount);
      
      // Set flag to indicate user just signed in
      await _prefs.setBool('just_signed_in', true);
      
      print('Local registration completed successfully');
    } catch (e) {
      print('Registration error: $e');
      throw e; // Re-throw to handle in UI
    }
  }

  // Sign in existing user
  Future<void> signInUser({required String email, required String password}) async {
    try {
      await _authService.signIn(email: email, password: password);
      
      // Update local storage with user info
      final user = _authService.currentUser;
      if (user != null) {
        await _prefs.setString('user_name', user.displayName ?? 'User');
        await _prefs.setString('user_email', user.email ?? '');
        await _prefs.setBool('is_registered', true);
        
        // Set flag to indicate user just signed in
        await _prefs.setBool('just_signed_in', true);
        
        // Only attempt Firestore operations if enabled
        if (_useFirestore) {
          try {
            // Try to get user data from Firestore
            final userData = await _firestore.collection('users').doc(user.uid).get();
            if (userData.exists) {
              await _prefs.setInt('remaining_speeches', userData['remainingSpeeches'] ?? maxDailySpeechCount);
            } else {
              // If user document doesn't exist, set default value
              await _prefs.setInt('remaining_speeches', maxDailySpeechCount);
            }
            print('Firestore user data retrieved successfully');
          } catch (e) {
            // Log Firestore error but continue with default values
            print('Error retrieving Firestore data: $e');
            print('Using default speech count');
            await _prefs.setInt('remaining_speeches', maxDailySpeechCount);
          }
        } else {
          print('Firestore operations disabled, using local storage only');
          await _prefs.setInt('remaining_speeches', maxDailySpeechCount);
        }
        
        print('Sign in completed successfully');
      }
    } catch (e) {
      print('Sign in error: $e');
      throw e; // Re-throw to handle in UI
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    await resetUser();
    
    // Set a flag to indicate the user just signed out
    await _prefs.setBool('just_signed_out', true);
    
    // Ensure is_registered is set to false
    await _prefs.setBool('is_registered', false);
    
    // Ensure has_used_first_speech is set to true to prevent showing free trial again
    await _prefs.setBool('has_used_first_speech', true);
  }

  Future<int> getRemainingSpeeches() async {
    // Skip Firestore operations if disabled or user not logged in
    if (_useFirestore && isLoggedIn()) {
      try {
        // Try to get from Firestore for logged in users
        await _checkAndResetDailyFirestore()
            .timeout(const Duration(seconds: 1), onTimeout: () {
          print('Firestore check/reset timed out, using local storage');
          return;
        });
        
        final userId = getUserId();
        if (userId != null) {
          try {
            final userData = await _firestore.collection('users').doc(userId).get()
                .timeout(const Duration(seconds: 1));
            if (userData.exists) {
              return userData['remainingSpeeches'] ?? maxDailySpeechCount;
            }
          } catch (e) {
            print('Error retrieving remaining speeches from Firestore: $e');
            print('Falling back to local storage');
            // Continue to fallback to local storage
          }
        }
      } catch (e) {
        print('Error retrieving remaining speeches from Firestore: $e');
        print('Falling back to local storage');
        // Continue to fallback to local storage
      }
    } else {
      print('Using local storage for speech count (Firestore disabled or user not logged in)');
    }
    
    // Fallback to local storage
    try {
      await _checkAndResetDaily();
      // For remaining speeches, we need to invert the count
      // since we store used speeches locally
      final usedSpeeches = _prefs.getInt(_speechCountKey) ?? 0;
      return maxDailySpeechCount - usedSpeeches;
    } catch (e) {
      print('Error retrieving remaining speeches from local storage: $e');
      // Return default value if all else fails
      return maxDailySpeechCount;
    }
  }

  Future<void> decrementSpeechCount() async {
    // Only attempt Firestore operations if enabled and user is logged in
    if (_useFirestore && isLoggedIn()) {
      try {
        // Try to update in Firestore for logged in users
        final userId = getUserId();
        if (userId != null) {
          await _checkAndResetDailyFirestore();
          final userRef = _firestore.collection('users').doc(userId);
          
          // Use a transaction to safely update the count
          await _firestore.runTransaction((transaction) async {
            final userData = await transaction.get(userRef);
            if (userData.exists) {
              final remaining = userData['remainingSpeeches'] ?? 0;
              if (remaining > 0) {
                transaction.update(userRef, {
                  'remainingSpeeches': remaining - 1,
                });
              }
            }
          });
          print('Speech count decremented in Firestore');
        }
      } catch (e) {
        print('Error decrementing speech count in Firestore: $e');
        print('Falling back to local storage only');
        // Continue to update locally
      }
    }
    
    // Always update locally for reliability
    await _checkAndResetDaily();
    final currentCount = _prefs.getInt(_speechCountKey) ?? 0;
    if (currentCount < maxDailySpeechCount) {
      await _prefs.setInt(_speechCountKey, currentCount + 1);
      print('Speech count decremented in local storage');
    }
  }

  Future<void> _checkAndResetDailyFirestore() async {
    // Skip if Firestore is disabled
    if (!_useFirestore) {
      print('Skipping Firestore reset check (Firestore disabled)');
      return;
    }
    
    try {
      final userId = getUserId();
      if (userId == null) return;
      
      // Add timeout to prevent long delays
      final userRef = _firestore.collection('users').doc(userId);
      final userData = await userRef.get()
          .timeout(const Duration(seconds: 1), onTimeout: () {
        print('Firestore get timed out in _checkAndResetDailyFirestore');
        throw TimeoutException('Firestore operation timed out');
      });
      
      if (userData.exists) {
        final lastReset = DateTime.fromMillisecondsSinceEpoch(
          userData['lastReset'] ?? 0
        );
        final now = DateTime.now();
        
        if (!_isSameDay(lastReset, now)) {
          try {
            await userRef.update({
              'remainingSpeeches': maxDailySpeechCount,
              'lastReset': now.millisecondsSinceEpoch,
            }).timeout(const Duration(seconds: 1), onTimeout: () {
              print('Firestore update timed out in _checkAndResetDailyFirestore');
              throw TimeoutException('Firestore update operation timed out');
            });
            print('Reset daily speech count in Firestore');
          } catch (e) {
            print('Error updating Firestore in _checkAndResetDailyFirestore: $e');
            // Silently fail and rely on local storage
          }
        }
      }
    } catch (e) {
      print('Error checking/resetting daily Firestore: $e');
      // Silently fail and rely on local storage
    }
  }

  Future<void> _checkAndResetDaily() async {
    final lastReset = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(_lastResetKey) ?? 0
    );
    final now = DateTime.now();

    if (!_isSameDay(lastReset, now)) {
      await _prefs.setInt(_speechCountKey, 0);
      await _prefs.setInt(_lastResetKey, now.millisecondsSinceEpoch);
      print('Reset daily speech count in local storage');
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Check if it's a new day and reset speech count if needed
  Future<void> checkAndResetSpeechCount() async {
    if (_useFirestore && isLoggedIn()) {
      await _checkAndResetDailyFirestore();
    }
    // Always check local storage for reliability
    await _checkAndResetDaily();
  }

  bool hasUsedFirstSpeech() {
    // If user is registered or logged in, they've already used their free trial
    // or they're a registered user who doesn't need a trial
    if (isRegistered() || isLoggedIn()) {
      return true;
    }
    
    // Otherwise check the flag for unregistered users
    return _prefs.getBool('has_used_first_speech') ?? false;
  }

  Future<void> markFirstSpeechAsUsed() async {
    await _prefs.setBool('has_used_first_speech', true);
  }

  bool isRegistered() {
    // First check if user is logged in with Firebase
    if (isLoggedIn()) {
      return true;
    }
    
    // Then check local storage, but only if not logged out recently
    final wasSignedOut = _prefs.getBool('just_signed_out') ?? false;
    if (wasSignedOut) {
      return false;
    }
    
    return _prefs.getBool('is_registered') ?? false;
  }

  String? getUserName() {
    return _authService.currentUser?.displayName ?? _prefs.getString('user_name');
  }

  String? getUserEmail() {
    return _authService.currentUser?.email ?? _prefs.getString('user_email');
  }

  Future<void> resetUser() async {
    await _prefs.remove('user_name');
    await _prefs.remove('user_email');
    await _prefs.remove('is_registered');
    // Don't remove has_used_first_speech to prevent showing free trial again
    await _prefs.remove('remaining_speeches');
    await _prefs.remove(_speechCountKey);
    await _prefs.remove(_lastResetKey);
    
    // Reset just_signed_in and just_signed_out flags
    await _prefs.setBool('just_signed_in', false);
    await _prefs.setBool('just_signed_out', false);
  }
} 