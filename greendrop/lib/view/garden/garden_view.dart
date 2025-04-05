import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart'; // Import your UserProvider
import 'package:provider/provider.dart'; // Import the provider package

class GardenView extends StatelessWidget {
  const GardenView({super.key});

  @override
  Widget build(BuildContext context) {
    // We'll use Consumer to listen for changes in the UserProvider
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Get the list of ALL trees (even the ones the user starts with)
        final allTrees = userProvider.user.trees; // Assuming your User class has a list of all possible trees

        return Scaffold(
          body: ListView.builder(
            itemCount: allTrees.length,
            itemBuilder: (context, index) {
              final tree = allTrees[index];
              String imagePath = 'assets/tree.png'; // Default 
              for (final level in tree.levels) {
                if (level.levelNumber == 1) {
                  imagePath = level.levelPicture;
                  break;
                }
              }
              return TreeCard(
                name: tree.name,
                price: tree.price,
                imagePath: imagePath,
                isLocked: false, // For now, no trees are locked in the display
              );
            },
          ),
        );
      },
    );
  }
}

class TreeCard extends StatelessWidget {
  final String name;
  final int price;
  final String imagePath;
  final bool isLocked;

  const TreeCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 50,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Text('${price} coins'),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock),
          ],
        ),
      ),
    );
  }
}