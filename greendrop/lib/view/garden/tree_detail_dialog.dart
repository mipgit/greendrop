import 'package:flutter/material.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

class TreeDetailDialog extends StatelessWidget {
  final Tree tree;
  final String imagePath;

  const TreeDetailDialog({
    super.key,
    required this.tree,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isOwned = context.watch<UserProvider>().user.ownedTrees.any((ownedTree) => ownedTree['treeId'] == tree.id);
    final canAfford = userProvider.user.droplets >= tree.price;
    const IconData dropletIcon = Icons.water_drop;

    // --- CORRECTED Brightness Calculation ---
    // Get the actual primary color from the theme
    final Color primaryButtonColor = Theme.of(context).primaryColor;
    // Estimate its brightness
    final Brightness estimatedBrightness = ThemeData.estimateBrightnessForColor(primaryButtonColor);
    // Determine contrasting text color
    final Color buttonTextColor = estimatedBrightness == Brightness.dark
        ? Colors.white // Use white text on dark backgrounds
        : Colors.black; // Use black text on light backgrounds

    // --- OR Simplest Fix: Hardcode if you know your theme ---
    // If your primary color is always green/dark, just use white:
    // final Color buttonTextColor = Colors.white;
    // -----------------------------------------------------


    return AlertDialog(
      title: Text(tree.name, textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 120,
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
            Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Text(
                   'Cost: ',
                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                 ),
                 Icon(dropletIcon, size: 18, color: Theme.of(context).primaryColor),
                 const SizedBox(width: 4),
                 Text(
                   '${tree.price}',
                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                 ),
               ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        if (isOwned)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white, // Keep text white on grey
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You already own ${tree.name}!"), 
                  duration: Duration(seconds: 1),
                ),
              );
               Navigator.of(context).pop();
            },
            child: const Text('Bought'),
          )
        else // Not owned
          ElevatedButton(
            style: ElevatedButton.styleFrom(
               backgroundColor: canAfford ? primaryButtonColor : Colors.grey, // Use the stored color
               // Use foregroundColor for simplicity and better practice:
               foregroundColor: canAfford ? buttonTextColor : Colors.white, // Set contrast text color (white on grey if disabled)
            ),
            onPressed: canAfford ? () {
              // ... purchase logic ...
               try {
                  userProvider.buyTree(context, tree.id);
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                         content: Text('${tree.name} purchased!'),
                         duration: Duration(seconds: 1),
                         backgroundColor: Colors.green,
                     ),
                   );
                  Navigator.of(context).pop();
              } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Error purchasing: $e')),
                   );
              }
            } : null,
            // The foregroundColor in styleFrom handles the text color now
            child: Text('Buy'),
            // Remove the explicit TextStyle if using foregroundColor:
            // child: Text(
            //   'Buy (${tree.price})',
            //   style: TextStyle(
            //     color: buttonTextColor,
            //   ),
            // ),
          ),
      ],
    );
  }
}