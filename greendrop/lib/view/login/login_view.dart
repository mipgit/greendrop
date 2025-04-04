import 'package:flutter/material.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthenticationService>(context);
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: provider.signIn, child: Text('Sign in with Google.')),
      ),
    );
  }
}