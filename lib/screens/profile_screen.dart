import 'package:flutter/material.dart';
import 'dart:async';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import '../widgets/custom_notification.dart';
import '../widgets/registration_screen.dart';
import '../home_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Cache for user data
  static String? _cachedUserName;
  static String? _cachedUserEmail;
  static int _cachedRemainingSpeeches = 0;
  static bool _isDataCached = false;
  
  // Local state
  bool _isLoading = true;
  late UserService _userService;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    
    // Reset cached data flag to force a refresh when profile screen is opened
    _isDataCached = false;
    
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Start a timeout timer to prevent infinite loading
    _timeoutTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isLoading) {
        print('ProfileScreen: Loading timed out, using cached data');
        setState(() {
          _isLoading = false;
        });
      }
    });

    try {
      // Create UserService instance - this should be quick as it's just getting SharedPreferences
      _userService = await UserService.create();
      
      // If we already have cached data, use it immediately
      if (_isDataCached) {
        print('ProfileScreen: Using cached data');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      
      // Otherwise load data with a timeout
      await _loadUserData();
    } catch (e) {
      print('Error initializing profile data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    print('ProfileScreen: Loading user data');
    
    try {
      // First check authentication status
      final isRegistered = _userService.isRegistered();
      final isLoggedIn = _userService.isLoggedIn();
      
      print('ProfileScreen: isRegistered=$isRegistered, isLoggedIn=$isLoggedIn');
      
      // Force refresh user data from UserService
      final userName = _userService.getUserName();
      final userEmail = _userService.getUserEmail();
      
      // Use a timeout for Firestore operations
      final remainingFuture = _userService.getRemainingSpeeches()
          .timeout(const Duration(seconds: 2), onTimeout: () {
        print('ProfileScreen: Firestore timeout, using default value');
        return 10; // Default value if Firestore times out
      });
      
      final remaining = await remainingFuture;
      
      if (!mounted) return;
      
      if (!isRegistered && !isLoggedIn) {
        print('ProfileScreen: User not authenticated, using default values');
        _cachedUserName = 'Guest User';
        _cachedUserEmail = 'Not signed in';
        _cachedRemainingSpeeches = 0;
      } else {
        print('ProfileScreen: User is authenticated, using actual values');
        _cachedUserName = userName ?? 'Guest User';
        _cachedUserEmail = userEmail ?? 'Not signed in';
        _cachedRemainingSpeeches = remaining;
        
        // Log the values for debugging
        print('ProfileScreen: Loaded userName=$_cachedUserName, email=$_cachedUserEmail');
      }
      
      _isDataCached = true;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      print('ProfileScreen: Data loaded - userName=$_cachedUserName, speeches=$_cachedRemainingSpeeches');
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    print('Sign out process started');
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Double-check if user is actually logged in
      final isLoggedIn = _userService.isLoggedIn();
      final isRegistered = _userService.isRegistered();
      
      print('Sign out: isLoggedIn=$isLoggedIn, isRegistered=$isRegistered');
      
      if (!isLoggedIn && !isRegistered) {
        print('User is not logged in, no need to sign out');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          showCustomNotification(context, 'You are not logged in');
        }
        return;
      }
      
      print('Calling userService.signOut()');
      await _userService.signOut();
      print('userService.signOut() completed');
      
      if (!mounted) return;
      
      // Clear cached data
      _isDataCached = false;
      _cachedUserName = 'Guest User';
      _cachedUserEmail = 'Not signed in';
      _cachedRemainingSpeeches = 0;
      
      // Show notification
      showCustomNotification(context, 'Successfully signed out');
      
      // Navigate back to home screen with a complete reset of the navigation stack
      print('Navigating back to home screen with complete reset');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false
      );
    } catch (e) {
      print('Error during sign out: $e');
      if (mounted) {
        showCustomNotification(context, 'Error signing out: $e', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    print('ProfileScreen dispose called');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    final theme = Theme.of(context);

    // Quick loading indicator for initial load
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Double-check authentication status directly from UserService
    final isLoggedIn = _userService.isLoggedIn();
    final isRegistered = _userService.isRegistered();
    final isAuthenticated = isLoggedIn || isRegistered;
    
    print('ProfileScreen build: isLoggedIn=$isLoggedIn, isRegistered=$isRegistered');
    
    // If authentication status doesn't match cached data, refresh
    if ((isAuthenticated && _cachedUserName == 'Guest User') || 
        (!isAuthenticated && _cachedUserName != 'Guest User')) {
      print('ProfileScreen: Authentication status mismatch, refreshing data');
      // Schedule a refresh after build
      Future.microtask(() => _loadUserData());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => themeService.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _cachedUserName?.isNotEmpty == true
                            ? _cachedUserName!.substring(0, 1).toUpperCase()
                            : 'G',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _cachedUserName ?? 'Guest User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _cachedUserEmail ?? 'Not signed in',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _cachedRemainingSpeeches > 0
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Remaining speeches: $_cachedRemainingSpeeches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _cachedRemainingSpeeches > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Account settings section
            Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Change your name and profile picture',
              onTap: () {
                showCustomNotification(context, 'Edit profile feature coming soon');
              },
              isDark: isDark,
              theme: theme,
            ),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Configure notification settings',
              onTap: () {
                showCustomNotification(context, 'Notification settings coming soon');
              },
              isDark: isDark,
              theme: theme,
            ),
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'Change app language',
              onTap: () {
                showCustomNotification(context, 'Language settings coming soon');
              },
              isDark: isDark,
              theme: theme,
            ),
            const SizedBox(height: 32),

            // Subscription section
            Text(
              'Subscription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.star,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Free Plan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '10 speeches per day',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showCustomNotification(context, 'Premium plans coming soon!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Upgrade'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sign out button - only show if user is truly authenticated
            if (isLoggedIn || isRegistered)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 