import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pizza_delivery_app/login.dart';

// Define the SplashScreen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// Define the state for the SplashScreen
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Declare animation controllers and animations
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _textAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a 2-second duration
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the main animation for the splash screen (fade in and out)
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    )..addListener(() {
        // Trigger a rebuild whenever the animation updates
        setState(() {});
      });

    // Define the text fade-in animation
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Define the pulse animation for the logo
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticInOut,
      ),
    );

    // Start the animation
    _controller.forward();

    // Navigate to the LoginPage after a 5-second delay
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    // Dispose of the animation controller when not needed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set up the splash screen layout
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Color.fromARGB(255, 255, 125, 86)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scale and fade in the logo with a pulse effect
              ScaleTransition(
                scale: _pulseAnimation,
                child: FadeTransition(
                  opacity: _animation,
                  child: Image.asset(
                    'assets/pizza_logo.png', // Your pizza app logo
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Show a circular progress indicator while loading
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              // Fade in the text (if needed, add text or other widgets here)
              FadeTransition(
                opacity: _textAnimation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
