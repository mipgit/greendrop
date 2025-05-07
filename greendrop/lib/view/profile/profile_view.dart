import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:intl/intl.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String profileAvatarHeroTag = 'profile-avatar-hero';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _bioController;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _bioController = TextEditingController(text: userProvider.user.bio ?? '');
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _saveBio() {
     if (mounted) {
       final userProvider = Provider.of<UserProvider>(context, listen: false);
       final currentText = _bioController.text;
       if (userProvider.user.bio?.trim() != currentText.trim()) {
         final textToSave = currentText.length > 100
             ? currentText.substring(0, 100)
             : currentText;
         userProvider.updateUserBio(textToSave.trim());
         print("Bio saved: ${textToSave.trim()}");
       } else {
         print("Bio unchanged, not saving.");
       }
     }
  }


  @override
  Widget build(BuildContext context) {

    if (_isSigningOut) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }



    final userProvider = Provider.of<UserProvider>(context);
    final authService = Provider.of<AuthenticationService>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final int treeCount = userProvider.userTrees.length;
    final int totalDropletsUsed = userProvider.userTrees.fold(0, (prev, tree) => prev + tree.dropletsUsed,);
    final formatter = NumberFormat('#,##0', 'en_US');
    final String formattedDroplets = formatter.format(totalDropletsUsed);

    final BorderRadius boxBorderRadius = BorderRadius.circular(15.0);


    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: ProfilePage.profileAvatarHeroTag,
                child: CircleAvatar(
                  radius: 75, 
                  //backgroundColor: colorScheme.primaryContainer.withOpacity(0.7),
                  backgroundImage: userProvider.user.profilePicture != null
                      ? NetworkImage(userProvider.user.profilePicture!)
                      : null,
                  child: userProvider.user.profilePicture == null
                      ? Icon(Icons.person_rounded, size: 80)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                userProvider.user.username,
                style: textTheme.headlineMedium?.copyWith( 
                  fontWeight: FontWeight.w500, 
                  color: colorScheme.onSurface, 
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                userProvider.user.email,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30), 


              // --- BIO TEXTFIELD  ---
              Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    _saveBio();
                  }
                },
                child: TextField(
                  controller: _bioController,
                  maxLength: 100,
                  maxLines: 4,
                  minLines: 2,
                  keyboardType: TextInputType.multiline,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveBio(),
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), // Style for typed text
                  decoration: InputDecoration(
                    hintText: 'Tell us a bit about yourself...',
                    hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                    filled: true,
                    fillColor: colorScheme.secondaryContainer.withOpacity(0.3),
                    counterStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: boxBorderRadius,
                      borderSide: BorderSide.none, 
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: boxBorderRadius,
                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3), width: 1.0),
                    ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: boxBorderRadius,
                        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                      ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
              // --- END OF BIO TEXTFIELD ---


              const SizedBox(height: 25), 


              // --- STATS BOX  ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: boxBorderRadius, 
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Stats",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600, 
                        color: colorScheme.onPrimaryContainer, 
                       ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.park_rounded, 
                          size: 20,
                          color: colorScheme.primary,
                         ),
                        const SizedBox(width: 10),
                        Text(
                          "Trees Planted:", 
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.9)),
                        ),
                        const Spacer(), 
                        Text(
                          "$treeCount", 
                           style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: colorScheme.outline.withOpacity(0.2)), 
                    const SizedBox(height: 10),
                    Row(
                      children: [
                         Icon(
                           Icons.opacity_rounded, 
                           size: 20,
                           color: colorScheme.secondary, 
                          ),
                         const SizedBox(width: 10),
                         Text(
                          "Droplets Spent:", 
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.9)),
                        ),
                        const Spacer(), 
                        Text(
                          formattedDroplets, 
                           style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // --- END OF STATS BOX ---


              const SizedBox(height: 40), 
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_isSigningOut) return;
                    
                    setState(() {
                      _isSigningOut = true;
                    });
                    _saveBio();

                    try {
                      await authService.signOut();
                      Navigator.of(context).pop();
                    } catch (e) {
                      print("Sign out error: $e");
                      if (mounted) {
                        setState(() {
                          _isSigningOut = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sign out failed. Please try again.')),
                        );
                      }
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Padding( 
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Sign Out'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}