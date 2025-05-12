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
    final userProvider = context.read<UserProvider>(); 
    final isOwned = context.watch<UserProvider>().user.ownedTrees.any((t) => t['treeId'] == tree.id);
    final canAfford = userProvider.user.droplets >= tree.price;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formatter = NumberFormat('#,##0', 'en_US'); 

    Color getButtonTextColor(Color backgroundColor) {
       return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
           ? Colors.white
           : Colors.black;
    }

    final ButtonStyle? buttonStyle = Theme.of(context).elevatedButtonTheme.style;
    final Color enabledButtonBg = buttonStyle?.backgroundColor?.resolve({}) ?? colorScheme.primary; 
    final Color disabledButtonBg = buttonStyle?.backgroundColor?.resolve({WidgetState.disabled}) ?? Colors.grey.shade400;
    final Color enabledButtonFg = buttonStyle?.foregroundColor?.resolve({}) ?? getButtonTextColor(enabledButtonBg);
    final Color disabledButtonFg = buttonStyle?.foregroundColor?.resolve({WidgetState.disabled}) ?? getButtonTextColor(disabledButtonBg);


    return AlertDialog(
      backgroundColor: colorScheme.surface, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text(
        tree.name,
        textAlign: TextAlign.center,
        style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect( 
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                imagePath,
                height: 130, 
                fit: BoxFit.contain,
                 errorBuilder: (context, error, stackTrace) => Container( 
                   height: 130,
                   width: 130,
                   //fix opacity thing!!!!
                   color: colorScheme.secondaryContainer.withOpacity(0.3),
                   child: Icon(Icons.park_rounded, size: 60, color: colorScheme.onSecondaryContainer.withOpacity(0.5)),
                 ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tree.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), 
            ),
            const SizedBox(height: 20), 
            Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(
                   'Cost: ',
                   style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                 ),
                 Icon(Icons.water_drop_rounded, size: 18, color: colorScheme.primary), 
                 const SizedBox(width: 4),
                 Text(
                    formatter.format(tree.price), 
                   style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                 ),
               ],
            ),
          ],
        ),
      ),

      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0), 
      actions: <Widget>[
        SizedBox( 
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
               backgroundColor: isOwned ? disabledButtonBg : (canAfford ? enabledButtonBg : disabledButtonBg),
               foregroundColor: isOwned ? disabledButtonFg : (canAfford ? enabledButtonFg : disabledButtonFg),
            ).merge(buttonStyle), 
            onPressed: isOwned ? null : (canAfford ? () { 
               try {
                  userProvider.buyTree(context, tree.id);
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                         content: Text('${tree.name} purchased!'),
                         duration: const Duration(seconds: 2),
                         backgroundColor: Colors.green.shade600, 
                         behavior: SnackBarBehavior.floating, 
                     ),
                   );
                  Navigator.of(context).pop();
              } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                        content: Text('Error purchasing: $e'),
                        backgroundColor: colorScheme.error, 
                        behavior: SnackBarBehavior.floating,
                      ),
                   );
              }
            } : null), 
            child: Text(isOwned ? 'Owned' : 'Buy Tree'),
          ),
        ),
      ],
    );
  }
}