import 'package:flutter/material.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

class TreeGardenCard extends StatelessWidget {
  final String name;
  final int price;
  final String imagePath;
  final Tree tree;
  final VoidCallback onCardTap; // Callback function when the card is tapped

  const TreeGardenCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.tree,
    required this.onCardTap, // Require the callback
  });

  @override
  Widget build(BuildContext context) {
    // Listen to UserProvider changes to update the 'Owned!' status
    final isOwned = context.watch<UserProvider>().user.ownedTrees.contains(tree.id);

    return Card(
      margin: const EdgeInsets.all(8.0),
      // Optional: Slightly change background if owned, or keep it consistent
      // color: isOwned ? Colors.green.withOpacity(0.1) : const Color.fromARGB(204, 219, 217, 217),
       color: const Color.fromARGB(204, 219, 217, 217), // Keep color consistent
      clipBehavior: Clip.antiAlias, // Ensures InkWell ripple stays within card bounds
      child: InkWell( // Make the whole card tappable
        onTap: onCardTap, // Use the passed callback
        child: SizedBox(
          height: 100.0,
          child: Row(
            children: [
              SizedBox(
                width: 100.0,
                height: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error), // Handle image load errors
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusted padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22.0, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // Add spacing
                      Text(
                        '${price} droplets', // Use 'droplets' for consistency
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Display "Owned!" text if the tree is owned
              if (isOwned)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "Owned!",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
               // Optionally add a price display here if NOT owned, if desired
               /* else
                 Padding(
                   padding: const EdgeInsets.only(right: 16.0),
                   child: Text(
                     '$price',
                     style: TextStyle(
                       fontSize: 16.0,
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).primaryColor,
                     ),
                   ),
                 ),
               */
            ],
          ),
        ),
      ),
    );
  }
}