import 'package:flutter/material.dart';
import 'sign_up_page.dart';

/// Simple splash screen widget for the Fluence Pay Merchant app.
/// Displays only the Fluence Pay logo on a clean background.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Navigate to signup page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0), // Cream background like in the image
      body: Center(
        child: Image.asset(
          'assets/images/fluence_logo.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image is not found
            return const Icon(
              Icons.business,
              size: 100,
              color: Color(0xFFB8860B),
            );
          },
        ),
      ),
    );
  }
}