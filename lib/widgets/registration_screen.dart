import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'registration_form.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onRegistrationComplete;
  final VoidCallback onCancel;

  const RegistrationScreen({
    Key? key,
    required this.onRegistrationComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Navigate to the detailed registration form
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegistrationForm(
          onRegistrationComplete: widget.onRegistrationComplete,
          onCancel: widget.onCancel,
        ),
      ),
    );
  }
  
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _cancel() async {
    await _animationController.reverse();
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                // Status bar and time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '9:41',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main content
                Expanded(
                  child: Column(
                    children: [
                      // Teddy bear image
                      Expanded(
                        flex: 5,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/images/teddy.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      
                      // Profile avatar
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/logo.png'),
                        ),
                      ),
                      
                      // Content section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const Text(
                              'Unlock Premium\nVoice Generation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Palanquin',
                                height: 1.2,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Register now to get 10 free speech generations daily. Create natural-sounding voices for your content.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                                fontFamily: 'Palanquin',
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B75F0),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Register Now',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Palanquin',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _cancel,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF5B75F0),
                                      side: const BorderSide(color: Color(0xFF5B75F0)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Maybe Later',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Palanquin',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                            
                            const SizedBox(height: 24),
                            
                            // Bottom indicator
                            Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 