import 'package:flutter/material.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart';
import 'package:greendrop/model/tree.dart'; // Import Tree model
import 'tree_detail_dialog.dart'; // Import the new dialog

class GardenView extends StatelessWidget {
  const GardenView({super.key});

  // Method to show the detail dialog
  void _showTreeDetailDialog(BuildContext context, Tree tree, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Important: Use dialogContext here if needed inside the dialog for specific actions
        // But for accessing providers, context should work fine if it's above the providers in the tree.
        // Pass the original context's UserProvider to the dialog
        return ChangeNotifierProvider.value(
          value: Provider.of<UserProvider>(context, listen: false),
          child: TreeDetailDialog(tree: tree, imagePath: imagePath),
        );

        // Alternative if not using Provider inside the dialog directly:
        // return TreeDetailDialog(
        //   tree: tree,
        //   imagePath: imagePath,
        //   // You might need to pass userProvider instance directly if needed
        //   // userProvider: Provider.of<UserProvider>(context, listen: false),
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer or Provider.of based on whether you need rebuilds here
    // Consumer is fine as it rebuilds the list when providers change
    return Consumer2<GardenProvider, UserProvider>(
      builder: (context, gardenProvider, userProvider, child) {
        final allTrees = gardenProvider.allAvailableTrees;

        // You might want to display the droplet count here as well
        final currentDroplets = userProvider.user.droplets;

        return Scaffold(
          // appBar: AppBar(title: Text('Garden - $currentDroplets Droplets')), // Optional: Show droplets
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Add vertical padding
            child: Column( // Wrap ListView in Column if adding other elements like title/droplet count
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Text(
                     "Your Droplets: $currentDroplets 💧",
                     style: Theme.of(context).textTheme.titleLarge,
                   ),
                 ),
                Expanded( // Important: ListView needs finite height within Column
                  child: ListView.builder(
                    itemCount: allTrees.length,
                    itemBuilder: (context, index) {
                      final tree = allTrees[index];
                      // Logic to get imagePath remains the same
                      String imagePath = 'assets/tree.png'; // Default
                       try { // Add try-catch for safety
                        final level1 = tree.levels.firstWhere(
                          (level) => level.levelNumber == 1,
                          // orElse: () => null, // Handle case where level 1 might not exist
                        );
                         imagePath = level1.levelPicture;
                      } catch (e) {
                        print("Warning: Could not find level 1 image for ${tree.name}. Using default.");
                        // Use default imagePath if level 1 not found
                      }


                      return TreeGardenCard(
                        name: tree.name,
                        price: tree.price,
                        imagePath: imagePath,
                        tree: tree,
                        // Pass the callback function, wrapping it to include specific tree data
                        onCardTap: () {
                          _showTreeDetailDialog(context, tree, imagePath);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
