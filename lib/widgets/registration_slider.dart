import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationSlider extends StatefulWidget {
  final VoidCallback onRegistrationComplete;
  final VoidCallback onCancel;

  const RegistrationSlider({
    Key? key,
    required this.onRegistrationComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  _RegistrationSliderState createState() => _RegistrationSliderState();
}

class _RegistrationSliderState extends State<RegistrationSlider> with SingleTickerProviderStateMixin {
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
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }
    
    if (!_isValidEmail(_emailController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return;
    }
    
    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });
    
    try {
      // Save user info to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_email', _emailController.text);
      await prefs.setBool('is_registered', true);
      
      // In a real app, you would also send this data to your backend
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      widget.onRegistrationComplete();
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: $e';
        _isRegistering = false;
      });
    }
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: const Color(0xFF909090),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, -3),
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Color(0xFF909090),
                blurRadius: 1,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Register to Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Palanquin',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF909090),
                    ),
                    onPressed: _cancel,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'To generate more speech, please register with your details.',
                style: TextStyle(
                  color: Color(0xFF909090),
                  fontSize: 14,
                  fontFamily: 'Palanquin',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(
                    color: Color(0xFF909090),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF909090),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF909090),
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF909090),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Palanquin',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(
                    color: Color(0xFF909090),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF909090),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF909090),
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Color(0xFF909090),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Palanquin',
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf7d786),
                    foregroundColor: const Color(0xFF212121),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: const Color(0xFFf7d786).withOpacity(0.5),
                  ),
                  child: _isRegistering
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF212121)),
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Palanquin',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _cancel,
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: Color(0xFF909090),
                      fontFamily: 'Palanquin',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 