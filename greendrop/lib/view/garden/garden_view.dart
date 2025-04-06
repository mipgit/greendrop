import 'package:flutter/material.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart';
import 'package:greendrop/model/tree.dart';
import 'tree_detail_dialog.dart';

class GardenView extends StatelessWidget {
  const GardenView({super.key});

  void _showTreeDetailDialog(BuildContext context, Tree tree, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ChangeNotifierProvider.value(
          value: Provider.of<UserProvider>(context, listen: false),
          child: TreeDetailDialog(tree: tree, imagePath: imagePath),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GardenProvider, UserProvider>( // Still need UserProvider for isOwned check indirectly
      builder: (context, gardenProvider, userProvider, child) { // Keep userProvider parameter
        final allTrees = gardenProvider.allAvailableTrees;

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column( // Keep Column structure if you have other elements, or remove if just the list
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // REMOVED: Droplet count display
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Text(
                //     "Your Droplets: ${userProvider.user.droplets} 💧", // userProvider is available here
                //     style: Theme.of(context).textTheme.titleLarge,
                //   ),
                // ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allTrees.length,
                    itemBuilder: (context, index) {
                      final tree = allTrees[index];
                      String imagePath = 'assets/tree.png';
                       try {
                        final level1 = tree.levels.firstWhere(
                          (level) => level.levelNumber == 1,
                        );
                         imagePath = level1.levelPicture;
                      } catch (e) {
                        print("Warning: Could not find level 1 image for ${tree.name}. Using default.");
                      }

                      return TreeGardenCard(
                        name: tree.species,
                        price: tree.price,
                        imagePath: imagePath,
                        tree: tree,
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
