import 'package:flutter/material.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart'; 


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            CircleAvatar(
              radius: 80, 
              backgroundImage: userProvider.user.profilePicture != null
                  ? NetworkImage(userProvider.user.profilePicture!) 
                  : null, 
              child: userProvider.user.profilePicture == null
                  ? const Icon(Icons.person, size: 80) 
                  : null, 
            ),
            const SizedBox(height: 20), 
            Text(userProvider.user.username,
                style: const TextStyle(fontSize: 30)),
            Text(userProvider.user.email,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await authService.signOut();
                  Navigator.of(context).pop();
                },
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}