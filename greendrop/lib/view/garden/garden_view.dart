import 'package:flutter/material.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart';
import 'package:greendrop/model/tree.dart';
import 'tree_detail_dialog.dart';

// Define an enum for sorting options for type safety and clarity
enum GardenSortOption {
  priceLowToHigh,
  nameAZ,
  notOwned,
}

// Convert to StatefulWidget
class GardenView extends StatefulWidget {
  const GardenView({super.key});

  @override
  State<GardenView> createState() => _GardenViewState();
}

class _GardenViewState extends State<GardenView> {
  // State variable to hold the current sorting option
  GardenSortOption _selectedSortOption = GardenSortOption.priceLowToHigh; // Default sort

  // Helper function to show the dialog (moved inside State)
  void _showTreeDetailDialog(
    BuildContext context,
    Tree tree,
    String imagePath,
  ) {
    // Important: Use the BuildContext from the builder method or one derived from it,
    // NOT the stored context if this were called from initState or somewhere else.
    // Here it's okay as it's called from itemBuilder's context.
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Provide UserProvider down to the dialog
        return ChangeNotifierProvider.value(
          // Ensure we grab the UserProvider available in the current scope
          value: Provider.of<UserProvider>(context, listen: false),
          child: TreeDetailDialog(tree: tree, imagePath: imagePath),
        );
      },
    );
  }

  // Helper function to get display text for sort options
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

  // --- Sorting Logic ---
  List<Tree> _sortTrees(List<Tree> trees, GardenSortOption sortOption, UserProvider userProvider) {
    List<Tree> sortedList = List.from(trees); // Create a mutable copy

    switch (sortOption) {
      case GardenSortOption.priceLowToHigh:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case GardenSortOption.nameAZ:
        // Using species for sorting as it's shown on the card
        sortedList.sort((a, b) => a.species.toLowerCase().compareTo(b.species.toLowerCase()));
        break;
      case GardenSortOption.notOwned:
        // Custom sort: unowned first, then by price
        sortedList.sort((a, b) {
          bool aOwned = userProvider.user.ownedTrees.any((t) => t['treeId'] == a.id);
          bool bOwned = userProvider.user.ownedTrees.any((t) => t['treeId'] == b.id);

          if (!aOwned && bOwned) return -1; // a (not owned) comes before b (owned)
          if (aOwned && !bOwned) return 1;  // a (owned) comes after b (not owned)

          // If both have the same ownership status (both owned or both not owned), sort by price
          return a.price.compareTo(b.price);
        });
        break;
    }
    return sortedList;
  }
  // --- End Sorting Logic ---


  @override
  Widget build(BuildContext context) {
    // Use Consumer instead of Provider.of directly in build if you only need it here
    return Consumer2<GardenProvider, UserProvider>(
      builder: (context, gardenProvider, userProvider, child) {
        if (gardenProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (gardenProvider.error != null) {
           return Center(child: Text("Error loading trees: ${gardenProvider.error}"));
        }

        final allTrees = gardenProvider.allAvailableTrees;
        // Apply sorting
        final List<Tree> displayedTrees = _sortTrees(allTrees, _selectedSortOption, userProvider);

        return Scaffold(
          // Scaffold provides background, AppBar etc. if needed later
          backgroundColor: Theme.of(context).colorScheme.background, // Use theme background
          body: Padding(
            // Consistent padding
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column( // Use Column to place Dropdown above the list
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Sorting Dropdown ---
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 5.0),
                  child: DropdownButton<GardenSortOption>(
                    value: _selectedSortOption,
                    icon: const Icon(Icons.sort),
                    // Style the dropdown to match theme
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    underline: Container( // Simple underline
                      height: 1,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    onChanged: (GardenSortOption? newValue) {
                      if (newValue != null) {
                        setState(() { // Update state to trigger rebuild with new sort
                          _selectedSortOption = newValue;
                        });
                      }
                    },
                    // Generate dropdown items from the enum
                    items: GardenSortOption.values.map((GardenSortOption option) {
                      return DropdownMenuItem<GardenSortOption>(
                        value: option,
                        child: Text(_getSortOptionText(option)),
                      );
                    }).toList(),
                  ),
                ),
                // --- End Sorting Dropdown ---

                // --- Tree List ---
                Expanded( // Make the list take remaining space
                  child: displayedTrees.isEmpty
                      ? Center( // Handle case where filtered/sorted list is empty
                          child: Text(
                            "No trees match the current criteria.",
                            style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          // Use the sorted list
                          itemCount: displayedTrees.length,
                          itemBuilder: (context, index) {
                            final tree = displayedTrees[index];
                            // Default image path
                            String imagePath = 'assets/images/trees/default_tree.png'; // More specific default?
                            // Safely try to get the last level image
                            if (tree.levels.isNotEmpty) {
                               final lastLevel = tree.levels.last;
                               if(lastLevel.levelPicture.isNotEmpty) {
                                  imagePath = lastLevel.levelPicture;
                               } else {
                                  print("Warning: Empty image path for last level of ${tree.name}");
                               }
                            } else {
                               print("Warning: Tree ${tree.name} has no levels defined.");
                            }


                            return TreeGardenCard(
                              // Use tree.species or tree.name based on your preference
                              name: tree.species,
                              price: tree.price,
                              imagePath: imagePath,
                              tree: tree, // Pass the whole tree object
                              onCardTap: () {
                                // Pass the correct imagePath used by the card
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