import 'package:flutter/material.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart';
import 'package:greendrop/model/tree.dart';
import 'tree_detail_dialog.dart';


enum GardenSortOption {
  priceLowToHigh,
  nameAZ,
  owned,
  notOwned,
}

class GardenView extends StatefulWidget {
  const GardenView({super.key});

  @override
  State<GardenView> createState() => _GardenViewState();
}

class _GardenViewState extends State<GardenView> {
  GardenSortOption _selectedSortOption = GardenSortOption.priceLowToHigh; //default sort

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

  String _getSortOptionText(GardenSortOption option) {
    switch (option) {
      case GardenSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case GardenSortOption.nameAZ:
        return 'Name: A-Z';
      case GardenSortOption.owned:
        return 'Owned First';  
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
      case GardenSortOption.owned:
        sortedList.sort((a, b) {
          bool aOwned = userProvider.user.ownedTrees.any((t) => t['treeId'] == a.id);
          bool bOwned = userProvider.user.ownedTrees.any((t) => t['treeId'] == b.id);
          if (aOwned && !bOwned) return -1;
          if (!aOwned && bOwned) return 1;
          return a.price.compareTo(b.price);
        });
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

    //avoid the bottom nav bar
    final double bottomNavBarHeightPadding = 100.0; 

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
          backgroundColor: colorScheme.surface, 
          body: Padding(
            padding: EdgeInsets.only(left: 8.0, right: 12.0, top: 12.0, bottom: bottomNavBarHeightPadding, ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                // --- Styled Sorting Dropdown ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0, top: 5.0), 
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5), //FIX!!!
                    borderRadius: BorderRadius.circular(20.0), 
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<GardenSortOption>(
                      value: _selectedSortOption,
                      isExpanded: true, 
                      icon: Icon(Icons.sort_rounded, color: colorScheme.primary), 
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      dropdownColor: colorScheme.surfaceContainerHighest, 
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
                            "No trees available.", 
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