import 'package:flutter/material.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting price

class TreeGardenCard extends StatelessWidget {
  final String name;
  final int price;
  final String imagePath;
  final Tree tree;
  final VoidCallback onCardTap;

  const TreeGardenCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.tree,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>(); // Use watch for reactivity
    final bool isOwned = userProvider.user.ownedTrees.any((ownedTree) => ownedTree['treeId'] == tree.id);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formatter = NumberFormat('#,##0', 'en_US'); // Formatter for price

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0), // Adjusted margins
      elevation: isOwned ? 1.0 : 2.0, // Slightly less elevation, subtle difference if owned
      // Use themed background colors
      color: isOwned ? colorScheme.primaryContainer.withOpacity(0.2) : colorScheme.surfaceVariant.withOpacity(0.7),
      // Consistent rounded shape
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Clip image to rounded corners
      child: InkWell(
        onTap: onCardTap,
        splashColor: colorScheme.primary.withOpacity(0.1), // Themed ripple
        highlightColor: colorScheme.primary.withOpacity(0.05),
        child: SizedBox(
          height: 110.0, // Slightly taller cards
          child: Row(
            children: [
              // Image container with fixed width
              SizedBox(
                width: 100.0,
                height: double.infinity, // Take full height
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  // Add a placeholder while loading (optional)
                  // placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorBuilder: (context, error, stackTrace) => Container( // Placeholder on error
                     color: colorScheme.secondaryContainer.withOpacity(0.3),
                     child: Icon(Icons.park_rounded, size: 40, color: colorScheme.onSecondaryContainer.withOpacity(0.5)),
                  ),
                ),
              ),
              // Text content section
              Expanded(
                child: Padding(
                  // More padding inside
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                    children: [
                      Text(
                        name, // Species name
                        style: textTheme.titleMedium?.copyWith( // Use titleMedium
                          fontWeight: FontWeight.w600, // Slightly bolder
                          color: colorScheme.onSurface, // Themed text color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row( // Row for droplet icon and price
                        children: [
                          Icon(Icons.water_drop_rounded, size: 16, color: colorScheme.primary), // Rounded droplet icon
                          const SizedBox(width: 4),
                          Text(
                             formatter.format(price), // Formatted price
                            style: textTheme.bodyMedium?.copyWith( // Use bodyMedium
                              color: colorScheme.primary, // Use primary color for price
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                           Text( // Add " droplets" text separately for potentially different styling
                            ' droplets',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant, // Softer color
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // "Owned" indicator
              if (isOwned)
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15), // Light primary bg
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    "Owned",
                    style: textTheme.labelSmall?.copyWith( // Use labelSmall
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary, // Use primary color
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}