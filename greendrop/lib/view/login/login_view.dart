import 'package:flutter/material.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
      body: SafeArea( // Use SafeArea to avoid notches/status bars
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0), // Add horizontal padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the column vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally within the column
              children: <Widget>[
                // 1. App Name
                Text(
                  'GreenDrop', // Your App Name
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary, // Use theme color
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24), // Spacing between name and icon

                // 2. App Icon
                Image.asset(
                  'assets/icon/greendrop.png', // Path to your icon
                  height: 120, // Adjust height as needed
                  // Optional: Add width if needed, or let height control aspect ratio
                  // width: 120,
                ),
                const SizedBox(height: 48), // Spacing between icon and button

                // 3. Sign-in Button
                ElevatedButton.icon( // Using .icon for a cleaner look with text+icon
                  onPressed: authService.signIn,
                  icon: const Icon(Icons.login), // Or use a Google specific icon if you have one
                  label: const Text('Sign in with Google.'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48), // Make button wider
                    textStyle: const TextStyle(fontSize: 16),
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
