import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for MaxLengthEnforcement
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart';

// Convert to StatefulWidget
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  // Keep the static tag if you still need it elsewhere
  static const String profileAvatarHeroTag = 'profile-avatar-hero';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controller to manage the TextField's text
  late TextEditingController _bioController;
  // Removed unused _isEditingBio field

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the user's current bio
    // Access provider *once* in initState using listen: false
    final userProvider = Provider.of<UserProvider>(context, listen: false);
      _bioController = TextEditingController(text: userProvider.user.bio ?? '');
    }

  @override
  void dispose() {
    // Clean up the controller and listener when the widget is removed
    // _debounce?.cancel(); // Cancel debounce timer if used
    // _bioController.removeListener(_handleBioChange); // Remove listener if used
    _bioController.dispose();
    super.dispose();
  }

  // Function to save the bio explicitly (e.g., on unfocus or button press)
  void _saveBio() {
     if (mounted) {
       final userProvider = Provider.of<UserProvider>(context, listen: false);
       // Only save if text actually changed and is different from current user bio
       if (userProvider.user.bio != _bioController.text) {
         userProvider.updateUserBio(_bioController.text);
         print("Bio saved: ${_bioController.text}");
       } else {
         print("Bio unchanged, not saving.");
       }
       // Optionally toggle edit state
       // setState(() { _isEditingBio = false; });
     }
  }


  @override
  Widget build(BuildContext context) {
    // Use Consumer here if parts of the UI need to rebuild when UserProvider changes
    // Or use Provider.of if you only need access in build methods / callbacks
    final userProvider = Provider.of<UserProvider>(context);
    final authService = Provider.of<AuthenticationService>(context, listen: false); // listen: false usually okay for services
    final colorScheme = Theme.of(context).colorScheme; // Get theme colors

    // Define the light green color
    final lightGreenColor = Colors.green.shade100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      // Use SingleChildScrollView to prevent overflow when keyboard appears
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: ProfilePage.profileAvatarHeroTag,
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
              Text(userProvider.user.username, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(userProvider.user.email, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 30), // Space before bio

              // --- BIO TEXTFIELD ---
              Focus( // Use Focus node to detect when field loses focus
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    _saveBio(); // Save when the text field loses focus
                  }
                },
                child: TextField(
                  controller: _bioController,
                  maxLength: 100, // Character limit
                  maxLines: 4,   // Maximum lines before scrolling starts
                  minLines: 2,   // Minimum lines height
                  keyboardType: TextInputType.multiline, // Allow multiple lines
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  textInputAction: TextInputAction.done, // Change keyboard action button
                   onSubmitted: (_) => _saveBio(), // Also save when 'done' is pressed
                  decoration: InputDecoration(
                    hintText: 'Tell us a bit about yourself...',
                    labelText: 'Bio',
                    filled: true,
                    fillColor: lightGreenColor, // Your light green color
                    // Counter style (optional)
                    counterStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    // Border definition
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none, // No visible border line
                    ),
                    enabledBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12.0),
                       borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0), // Subtle border when enabled
                    ),
                     focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12.0),
                       borderSide: BorderSide(color: colorScheme.primary, width: 1.5), // Highlight border when focused
                     ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
              // --- END OF BIO TEXTFIELD ---

              const SizedBox(height: 40), // Space after bio
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                     // Save bio one last time before signing out, just in case
                     _saveBio();
                     await Future.delayed(const Duration(milliseconds: 100)); // Small delay
                    await authService.signOut();
                    if (mounted && Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ),
              const SizedBox(height: 20), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }
}