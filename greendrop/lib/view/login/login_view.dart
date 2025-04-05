import 'package:flutter/material.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate

// Back to StatelessWidget
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);
    final Color googleButtonBackgroundColor = Colors.grey[100] ?? const Color(0xFFF5F5F5);
    final Color screenBackgroundColor = const Color(0xFFF0F7EF);
    final Color darkPastelGreen = Colors.green[800]!;

    // Define animation timings (optional but good practice)
    final Duration initialDelay = 300.ms; // Start animation after this delay
    final Duration iconDuration = 600.ms;
    final Duration buttonDelay = 200.ms; // Delay *after* the icon starts animating
    final Duration buttonDuration = 600.ms;
    final double slideAmount = 0.5; // How much to slide (0.5 = half height)

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // App Logo with Animation
                Image.asset(
                  'assets/icon/greendrop.png',
                  height: 200,
                )
                .animate() // Apply animations
                .fadeIn(delay: initialDelay, duration: iconDuration, curve: Curves.easeIn) // Fade in first
                .slideY(begin: slideAmount, end: 0, duration: iconDuration, curve: Curves.easeOut), // Then slide up

                const SizedBox(height: 24),

                // App Name (Could also be animated similarly if desired)
                Text(
                  'GreenDrop',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: darkPastelGreen,
                      ),
                  textAlign: TextAlign.center,
                )
                .animate() // Optional: Animate name too
                .fadeIn(delay: initialDelay + 100.ms, duration: iconDuration) // Slightly later fade
                .scaleXY(begin: 0.8, end: 1.0, duration: iconDuration, curve: Curves.easeOutBack), // Optional scale effect


                const SizedBox(height: 72),

                // Google Sign-in Button with Animation
                ElevatedButton.icon(
                  onPressed: authService.signIn,
                  icon: Image.asset(
                    'assets/icon/google.png',
                    height: 22.0,
                  ),
                  label: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    elevation: 1,
                    backgroundColor: googleButtonBackgroundColor,
                    foregroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                )
                .animate() // Apply animations
                .fadeIn(delay: initialDelay + buttonDelay, duration: buttonDuration, curve: Curves.easeIn) // Staggered fade in
                .slideY(begin: slideAmount, end: 0, duration: buttonDuration, curve: Curves.easeOut), // Staggered slide up
              ],
            ),
          ),
        ),
      ),
    );
  }
}