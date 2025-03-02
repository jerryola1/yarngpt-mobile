import 'package:flutter/material.dart';
import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isSigningIn = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }
    
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });
    
    try {
      // Get the user service
      final userService = await UserService.create();
      
      // Use the proper signInUser method instead of registerUser
      await userService.signInUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Navigate back to home screen without triggering speech generation
      if (mounted) {
        // Pop all screens until we reach the home screen
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign in failed: $e';
          _isSigningIn = false;
        });
      }
    }
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
                    'assets/images/guy.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Status bar with time and sign up button
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
                            // Go back to registration screen
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Sign up',
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
          
          // Sign in card (2/3 of screen)
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
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Palanquin',
                      ),
                    ),
                    const SizedBox(height: 30),
                    
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
                                ),
                              ],
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
                    
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSigningIn ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B75F0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSigningIn
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Palanquin',
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Social sign in options
                    const Center(
                      child: Text(
                        'or sign in with',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Palanquin',
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Social buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton(
                          icon: Icons.flutter_dash,
                          label: 'Twitter',
                          onTap: () {},
                        ),
                        _buildSocialButton(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          onTap: () {},
                        ),
                        _buildSocialButton(
                          icon: Icons.g_mobiledata,
                          label: 'Google',
                          onTap: () {},
                        ),
                      ],
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: const Color(0xFF5B75F0),
            size: 30,
          ),
        ),
      ),
    );
  }
} 