import 'package:flutter/material.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);
    final Color googleButtonBackgroundColor = Colors.grey[100] ?? const Color(0xFFF5F5F5);
    final Color screenBackgroundColor = const Color(0xFFF0F7EF);
    final Color darkPastelGreen = Colors.green[800]!; // Using a darker shade from Material palette

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
                // App Logo
                Image.asset(
                  'assets/icon/greendrop.png',
                  height: 200,
                ),
                const SizedBox(height: 24),

                // App Name (with Dark Pastel Green color)
                Text(
                  'GreenDrop',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: darkPastelGreen,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 72),

                // Google Sign-in Button
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}