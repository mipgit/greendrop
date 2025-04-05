import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart'; 
import 'package:provider/provider.dart'; 
import 'package:greendrop/view/garden/tree_garden_card.dart'; 
import 'package:greendrop/view/droplet_counter.dart';

class GardenView extends StatelessWidget {
  const GardenView({super.key});

   @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final allTrees = userProvider.user.trees;

        return Padding( 
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding( 
                padding: const EdgeInsets.all(8.0), 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, 
                  children: const [
                    DropletCounter(),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded( 
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
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
                        isLocked: false,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
