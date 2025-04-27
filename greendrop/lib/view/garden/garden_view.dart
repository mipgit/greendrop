import 'package:flutter/material.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart';
import 'package:greendrop/model/tree.dart';
import 'tree_detail_dialog.dart';

// Keep the enum
enum GardenSortOption {
  priceLowToHigh,
  nameAZ,
  notOwned,
}

class GardenView extends StatefulWidget {
  const GardenView({super.key});

  @override
  State<GardenView> createState() => _GardenViewState();
}

class _GardenViewState extends State<GardenView> {
  GardenSortOption _selectedSortOption = GardenSortOption.priceLowToHigh; // Default sort

  void _showTreeDetailDialog(BuildContext context, Tree tree, String imagePath) {
    showDialog(
      context: context,
      // Make dialog background slightly transparent for a modern feel
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext dialogContext) {
        return ChangeNotifierProvider.value(
          value: Provider.of<UserProvider>(context, listen: false),
          child: TreeDetailDialog(tree: tree, imagePath: imagePath),
        );
      },
    );
  }

  String _getSortOptionText(GardenSortOption option) {
    switch (option) {
      case GardenSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case GardenSortOption.nameAZ:
        return 'Name: A-Z';
      case GardenSortOption.notOwned:
        return 'Not Owned First';
    }
  }

  List<Tree> _sortTrees(List<Tree> trees, GardenSortOption sortOption, UserProvider userProvider) {
    List<Tree> sortedList = List.from(trees);
    switch (sortOption) {
      case GardenSortOption.priceLowToHigh:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case GardenSortOption.nameAZ:
        sortedList.sort((a, b) => a.species.toLowerCase().compareTo(b.species.toLowerCase()));
        break;
      case GardenSortOption.notOwned:
        sortedList.sort((a, b) {
          bool aOwned = userProvider.user.ownedTrees.any((t) => t['treeId'] == a.id);
          bool bOwned = userProvider.user.ownedTrees.any((t) => t['treeId'] == b.id);
          if (!aOwned && bOwned) return -1;
          if (aOwned && !bOwned) return 1;
          return a.price.compareTo(b.price);
        });
        break;
    }
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer2<GardenProvider, UserProvider>(
      builder: (context, gardenProvider, userProvider, child) {
        if (gardenProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }
        if (gardenProvider.error != null) {
           return Center(child: Text("Error loading trees: ${gardenProvider.error}"));
        }

        final allTrees = gardenProvider.allAvailableTrees;
        final List<Tree> displayedTrees = _sortTrees(allTrees, _selectedSortOption, userProvider);

        return Scaffold(
          backgroundColor: colorScheme.background, // Use theme background
          body: Padding(
            // More vertical padding, less horizontal if cards have margins
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
              children: [
                // --- Styled Sorting Dropdown ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0, top: 5.0), // Add horizontal margin
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5), // Subtle background
                    borderRadius: BorderRadius.circular(20.0), // More rounded
                  ),
                  child: DropdownButtonHideUnderline( // Hide default underline
                    child: DropdownButton<GardenSortOption>(
                      value: _selectedSortOption,
                      isExpanded: true, // Make dropdown take available width
                      icon: Icon(Icons.sort_rounded, color: colorScheme.primary), // Rounded icon, themed color
                      // Style the text shown in the button
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      dropdownColor: colorScheme.surfaceVariant, // Background of the dropdown menu
                      onChanged: (GardenSortOption? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSortOption = newValue;
                          });
                        }
                      },
                      items: GardenSortOption.values.map((GardenSortOption option) {
                        return DropdownMenuItem<GardenSortOption>(
                          value: option,
                          child: Text(
                            _getSortOptionText(option),
                            // Style the text within the dropdown menu items
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // --- End Sorting Dropdown ---

                // --- Tree List ---
                Expanded(
                  child: displayedTrees.isEmpty
                      ? Center(
                          child: Text(
                            "No trees available.", // Simpler text
                            style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedTrees.length,
                          itemBuilder: (context, index) {
                            final tree = displayedTrees[index];
                            String imagePath = 'assets/images/trees/default_tree.png';
                            if (tree.levels.isNotEmpty && tree.levels.last.levelPicture.isNotEmpty) {
                                imagePath = tree.levels.last.levelPicture;
                            } else {
                               print("Warning: Using default image for ${tree.name}");
                            }

                            // Pass the UserProvider down explicitly if needed by card (already done via context.watch)
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
                // --- End Tree List ---
              ],
            ),
          ),
        );
      },
    );
  }
}