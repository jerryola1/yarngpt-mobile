import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email & password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('Attempting to create user with Firebase Authentication');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user profile with name
      try {
        await userCredential.user?.updateDisplayName(name);
        print('User display name updated successfully');
      } catch (e) {
        print('Error updating display name: $e');
        // Continue even if setting display name fails
      }
      
      print('User created successfully in Firebase Authentication');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during sign up: ${e.code} - ${e.message}');
      String errorMessage;
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please sign in instead.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak. Please use a stronger password.';
          break;
        default:
          errorMessage = 'Registration failed. Please try again later.';
      }
      
      throw errorMessage;
    } catch (e) {
      print('Unexpected error during sign up: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email & password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to sign in user with Firebase Authentication');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in successfully');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during sign in: ${e.code} - ${e.message}');
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email. Please register first.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'Sign in failed. Please try again later.';
      }
      
      throw errorMessage;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during password reset: ${e.code} - ${e.message}');
      String errorMessage;
      
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        default:
          errorMessage = 'Failed to send password reset email. Please try again later.';
      }
      
      throw errorMessage;
    } catch (e) {
      print('Unexpected error during password reset: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}
