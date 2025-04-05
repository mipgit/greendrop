import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart'; 
import 'package:provider/provider.dart'; 
import 'package:greendrop/view/garden/tree_garden_card.dart'; 

class GardenView extends StatelessWidget {
  const GardenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Get the list of ALL trees 
        final allTrees = userProvider.user.trees; 

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
              return TreeGardenCard(
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