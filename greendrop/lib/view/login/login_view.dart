import 'package:flutter/material.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart'; 


class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);
    final Color googleButtonBackgroundColor = Colors.white; //we have to decide these colors
    final Color screenBackgroundColor = const Color(0xFFF0F7EF);
    final Color darkPastelGreen = Colors.green[800]!;

    final Duration initialDelay = 300.ms; 
    final Duration iconDuration = 600.ms;
    final Duration buttonDelay = 200.ms; 
    final Duration buttonDuration = 600.ms;
    final double slideAmount = 0.5; 

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
                .animate() 
                .fadeIn(delay: initialDelay, duration: iconDuration, curve: Curves.easeIn) 
                .slideY(begin: slideAmount, end: 0, duration: iconDuration, curve: Curves.easeOut), 

                const SizedBox(height: 24),

                // App Name 
                Text(
                  'GreenDrop',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: darkPastelGreen,
                      ),
                  textAlign: TextAlign.center,
                )
                .animate() 
                .fadeIn(delay: initialDelay + 100.ms, duration: iconDuration) 
                .scaleXY(begin: 0.8, end: 1.0, duration: iconDuration, curve: Curves.easeOutBack),

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
                .animate() 
                .fadeIn(delay: initialDelay + buttonDelay, duration: buttonDuration, curve: Curves.easeIn) 
                .slideY(begin: slideAmount, end: 0, duration: buttonDuration, curve: Curves.easeOut),
              
                const SizedBox(height: 16), 

                // Guest Sign-in Button with Animation
                ElevatedButton(
                  onPressed: authService.signInAnonymously,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    elevation: 1,
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Sign in as Guest',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .animate() 
                .fadeIn(delay: initialDelay + buttonDelay, duration: buttonDuration, curve: Curves.easeIn) 
                .slideY(begin: slideAmount, end: 0, duration: buttonDuration, curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}