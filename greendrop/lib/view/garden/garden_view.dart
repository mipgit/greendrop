import 'package:flutter/material.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart';
import 'package:greendrop/model/tree.dart';
import 'tree_detail_dialog.dart';

class GardenView extends StatelessWidget {
  const GardenView({super.key});

  void _showTreeDetailDialog(
    BuildContext context,
    Tree tree,
    String imagePath,
  ) {
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
    return Consumer2<GardenProvider, UserProvider>(
      builder: (context, gardenProvider, userProvider, child) {
        final allTrees = gardenProvider.allAvailableTrees;
        return Scaffold(
          body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: allTrees.isEmpty
            ? const Center(
                child: Text(
                  "No trees available for purchase.",
                  style: TextStyle(fontSize: 14.0),
                ),
              )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: allTrees.length,
                    itemBuilder: (context, index) {
                      final tree = allTrees[index];
                      String imagePath = 'assets/tree.png';
                      try {
                        if (tree.levels.isNotEmpty) {
                          imagePath = tree.levels.last.levelPicture;
                        }
                      } catch (e) {
                        print(
                          "Warning: Could not find last level image for ${tree.name}. Using default.",
                        );
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
