import 'package:flutter/material.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Define a static constant for the Hero tag for easy reuse
  static const String profileAvatarHeroTag = 'profile-avatar-hero';

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
            // Wrap the CircleAvatar with the Hero widget
            Hero(
              // Assign the unique tag
              tag: profileAvatarHeroTag,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: userProvider.user.profilePicture != null
                    ? NetworkImage(userProvider.user.profilePicture!)
                    : null,
                child: userProvider.user.profilePicture == null
                    ? const Icon(Icons.person, size: 80)
                    : null,
              ),
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
                  // Pop the profile page after signing out
                  if (Navigator.canPop(context)) {
                     Navigator.of(context).pop();
                  }
                  // You might want to navigate to a login/home screen here
                  // after the pop completes, depending on your app flow.
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