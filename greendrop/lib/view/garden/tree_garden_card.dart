import 'package:flutter/material.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

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
    //final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: isOwned ? 1.0 : 2.0,
      color: isOwned ? null : const Color.fromARGB(204, 226, 221, 221),
      child: InkWell(
        onTap: onCardTap,
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
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: textTheme.headlineSmall?.copyWith(fontSize: 25.0),
                      ),
                      const SizedBox(height: 6),
                      Row( 
                        children: [
                          Text(
                            '$price', 
                            style: textTheme.bodyMedium?.copyWith( 
                              color: Colors.grey, 
                              fontWeight: FontWeight.w500,
                            ),
                          ), 
                          //Icon(Icons.water_drop_rounded, size: 16, color: colorScheme.primary), 
                          Text(
                            ' droplets',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  isOwned ? Icons.check : Icons.add,
                  color: isOwned ? Colors.green : const Color.fromARGB(255, 0, 0, 0),
                  size: 30.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}