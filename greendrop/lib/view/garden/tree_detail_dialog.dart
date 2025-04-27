import 'package:flutter/material.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting price

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
    // Get providers and theme data
    final userProvider = context.read<UserProvider>(); // Use read if only needed for actions
    final isOwned = context.watch<UserProvider>().user.ownedTrees.any((t) => t['treeId'] == tree.id);
    final canAfford = userProvider.user.droplets >= tree.price;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formatter = NumberFormat('#,##0', 'en_US'); // Formatter

    // Determine button text color based on *button's* background (using ElevatedButtonTheme ideally)
    // This is a fallback if theme isn't set up perfectly
    Color getButtonTextColor(Color backgroundColor) {
       return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
           ? Colors.white
           : Colors.black;
    }
    // Get the actual button colors from the theme if possible
    final ButtonStyle? buttonStyle = Theme.of(context).elevatedButtonTheme.style;
    final Color enabledButtonBg = buttonStyle?.backgroundColor?.resolve({}) ?? colorScheme.primary; // Default to primary
    final Color disabledButtonBg = buttonStyle?.backgroundColor?.resolve({MaterialState.disabled}) ?? Colors.grey.shade400;
    final Color enabledButtonFg = buttonStyle?.foregroundColor?.resolve({}) ?? getButtonTextColor(enabledButtonBg);
    final Color disabledButtonFg = buttonStyle?.foregroundColor?.resolve({MaterialState.disabled}) ?? getButtonTextColor(disabledButtonBg);


    return AlertDialog(
      // Themed background and shape
      backgroundColor: colorScheme.surface, // Use surface color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Consistent rounding
      // Title styling
      title: Text(
        tree.name,
        textAlign: TextAlign.center,
        style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
      ),
      // Content styling
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect( // Clip image if needed
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                imagePath,
                height: 130, // Slightly larger image
                fit: BoxFit.contain,
                 errorBuilder: (context, error, stackTrace) => Container( // Placeholder on error
                   height: 130,
                   width: 130,
                   color: colorScheme.secondaryContainer.withOpacity(0.3),
                   child: Icon(Icons.park_rounded, size: 60, color: colorScheme.onSecondaryContainer.withOpacity(0.5)),
                 ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tree.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), // Softer color
            ),
            const SizedBox(height: 20), // More space
            // Cost display
            Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(
                   'Cost: ',
                   style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                 ),
                 Icon(Icons.water_drop_rounded, size: 18, color: colorScheme.primary), // Rounded icon
                 const SizedBox(width: 4),
                 Text(
                    formatter.format(tree.price), // Formatted price
                   style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                 ),
               ],
            ),
          ],
        ),
      ),
      // Actions styling
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0), // Adjust padding
      actions: <Widget>[
        SizedBox( // Constrain button width if needed
          width: 150,
          child: ElevatedButton(
            // Use the resolved theme colors for styling
            style: ElevatedButton.styleFrom(
               backgroundColor: isOwned ? disabledButtonBg : (canAfford ? enabledButtonBg : disabledButtonBg),
               foregroundColor: isOwned ? disabledButtonFg : (canAfford ? enabledButtonFg : disabledButtonFg),
               // Ensure shape matches theme or override consistently
               // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            ).merge(buttonStyle), // Merge with theme style
            onPressed: isOwned ? null : (canAfford ? () { // Disable button if owned
               try {
                  userProvider.buyTree(context, tree.id);
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                         content: Text('${tree.name} purchased!'),
                         duration: const Duration(seconds: 2),
                         backgroundColor: Colors.green.shade600, // Success color
                         behavior: SnackBarBehavior.floating, // Modern look
                     ),
                   );
                  Navigator.of(context).pop();
              } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                        content: Text('Error purchasing: $e'),
                        backgroundColor: colorScheme.error, // Error color
                        behavior: SnackBarBehavior.floating,
                      ),
                   );
              }
            } : null), // Disable button if cannot afford
            child: Text(isOwned ? 'Owned' : 'Buy Tree'),
          ),
        ),
      ],
    );
  }
}