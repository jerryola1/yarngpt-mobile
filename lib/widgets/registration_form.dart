import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/profile_screen.dart';

class RegistrationForm extends StatefulWidget {
  final VoidCallback onRegistrationComplete;
  final VoidCallback onCancel;

  const RegistrationForm({
    Key? key,
    required this.onRegistrationComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isRegistering = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  bool _isNameValid = false;
  bool _isEmailValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      _isNameValid = value.trim().isNotEmpty && value.trim().contains(' ');
    });
  }

  void _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(value);
    });
  }

  Future<void> _register() async {
    if (!_isNameValid || !_isEmailValid || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields correctly';
      });
      return;
    }
    
    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });
    
    try {
      // Get the user service
      final userService = await UserService.create();
      
      // Add a timeout to prevent hanging
      bool registrationCompleted = false;
      
      // Start a timeout timer
      Future.delayed(const Duration(seconds: 15), () {
        if (!registrationCompleted) {
          print('Registration timeout - forcing completion');
          setState(() {
            _isRegistering = false;
          });
          
          // If we've timed out but Firebase Auth might have succeeded,
          // we'll still try to complete the registration process
          _completeRegistration();
        }
      });
      
      // Register the user with password
      await userService.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Mark registration as completed to prevent timeout handler from executing
      registrationCompleted = true;
      
      // Complete the registration process
      _completeRegistration();
    } catch (e) {
      print('Registration error: $e');
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString().contains('firebase') ? 'Email may already be in use' : e}';
        _isRegistering = false;
      });
    }
  }
  
  void _completeRegistration() async {
    print('Completing registration process');
    
    // Set the just_signed_in flag to true
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('just_signed_in', true);
    
    // Set registration flag directly in case Firebase operations failed
    await prefs.setBool('is_registered', true);
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_email', _emailController.text);
    
    // Set initial speech count to 10
    await prefs.setInt('remaining_speeches', 10);
    
    // Reset UI state
    setState(() {
      _isRegistering = false;
    });
    
    // Call the completion callback
    widget.onRegistrationComplete();
    
    // Print debug information
    print('Registration complete, navigating to home screen directly');
    
    // Pop all screens until we reach the home screen
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // No need to navigate to profile screen anymore
    // Just let the home screen handle the logged-in state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top image section (1/3 of screen)
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Image.asset(
                    'assets/images/lady.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Status bar with time and sign in button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back arrow
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Text(
                          '9:41',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to sign in screen with sliding transition
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: Color(0xFF5B75F0),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: 'Palanquin',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Registration card (2/3 of screen)
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'New account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Palanquin',
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Full name field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.grey[600],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 12, bottom: 4),
                                  child: Text(
                                    'Full name',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Palanquin',
                                    ),
                                  ),
                                ),
                                TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Barbara Butler',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(right: 16, bottom: 12),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Palanquin',
                                  ),
                                  onChanged: _validateName,
                                ),
                              ],
                            ),
                          ),
                          if (_isNameValid)
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Icons.email_outlined,
                              color: Colors.grey[600],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 12, bottom: 4),
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Palanquin',
                                    ),
                                  ),
                                ),
                                TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'butlerbox@mail.com',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(right: 16, bottom: 12),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Palanquin',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: _validateEmail,
                                ),
                              ],
                            ),
                          ),
                          if (_isEmailValid)
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[600],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 12, bottom: 4),
                                  child: Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Palanquin',
                                    ),
                                  ),
                                ),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: const InputDecoration(
                                    hintText: '••••••••••',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(right: 16, bottom: 12),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Palanquin',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontFamily: 'Palanquin',
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 30),
                    
                    // Create account button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isRegistering ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B75F0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isRegistering
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Create an account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Palanquin',
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Terms and conditions
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: 'Palanquin',
                          ),
                          children: [
                            TextSpan(text: 'By signing up you agree to our\n'),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: Color(0xFF5B75F0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Conditions of Use',
                              style: TextStyle(
                                color: Color(0xFF5B75F0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Bottom indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Back button
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFF5B75F0),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Palanquin',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 