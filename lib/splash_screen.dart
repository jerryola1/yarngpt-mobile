// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F58E), // Light green background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and App Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 10),
                const Text(
                  'YarnGPT',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Audio Wave Animation
            SizedBox(
              height: 100,
              child: _buildAudioWaveAnimation(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Text to Speech',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioWaveAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return _buildAnimatedBar(index);
      }),
    );
  }

  Widget _buildAnimatedBar(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.3, end: 1.0),
        duration: Duration(milliseconds: 500 + (index * 200)),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            width: 8,
            height: 60 * value,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}
