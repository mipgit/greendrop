import 'package:flutter/material.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

class TreeDetailDialog extends StatelessWidget {
  final Tree tree;
  final String imagePath; // Pass the specific image path

  const TreeDetailDialog({
    super.key,
    required this.tree,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Access UserProvider but don't listen for rebuilds within the dialog itself
    // The logic depends on the state *when the dialog is built*
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isOwned = userProvider.user.ownedTrees.contains(tree.id);
    final canAfford = userProvider.user.droplets >= tree.price;
    final currentDroplets = userProvider.user.droplets;

    return AlertDialog(
      title: Text(tree.name, textAlign: TextAlign.center),
      content: SingleChildScrollView( // Use SingleChildScrollView if content might overflow
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for AlertDialog content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 120, // Adjust size as needed
              fit: BoxFit.contain,
               errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 120),
            ),
            const SizedBox(height: 16),
            Text(
              tree.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Cost: ${tree.price} droplets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
             Text(
              'Your Droplets: $currentDroplets',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center, // Center the button
      actions: <Widget>[
        if (isOwned)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey, // Visually indicate it's non-actionable
            ),
            onPressed: () {
              // Show "already owned" message and close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You already own ${tree.name}!")),
              );
               Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Already Owned'),
          )
        else // Not owned
          ElevatedButton(
            // Disable button visually if cannot afford - optional, but good UX
            // onPressed: canAfford ? () { ... } : null,
            style: ElevatedButton.styleFrom(
               backgroundColor: canAfford ? Theme.of(context).primaryColor : Colors.grey,
            ),
            onPressed: () {
              if (canAfford) {
                // Attempt purchase
                try {
                    userProvider.buyTree(context, tree.id);
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                           content: Text('${tree.name} purchased!'),
                           backgroundColor: Colors.green,
                       ),
                     );
                    Navigator.of(context).pop(); // Close dialog on success
                } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Error purchasing: $e')),
                     );
                     // Optionally close dialog on error too, or leave open
                     // Navigator.of(context).pop();
                }

              } else {
                // Show "not enough droplets" message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Not enough droplets!"),
                      backgroundColor: Colors.redAccent,
                   ),
                );
                // Don't close the dialog here, let the user see the message
              }
            },
            child: Text('Buy (${tree.price})'),
          ),
      ],
    );
  }
}