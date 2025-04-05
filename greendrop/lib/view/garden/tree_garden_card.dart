import 'package:flutter/material.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

class TreeGardenCard extends StatelessWidget {
  final String name;
  final int price;
  final String imagePath;
  final bool isLocked;
  final Tree tree;

  const TreeGardenCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    this.isLocked = false,
    required this.tree,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: tree.isBought ? null : const Color.fromARGB(255, 216, 214, 214),
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
                        style: const TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                      Text(
                        '${price} coins',
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector( 
              onTap: () {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (!tree.isBought) {
                  if (userProvider.user.droplets >= tree.price) {
                    userProvider.user.droplets -= tree.price;
                    final index = userProvider.user.ownedTrees.indexOf(tree.id);
                    if (index != -1) {
                      //userProvider.user.ownedTrees[index].isBought = true; -> SOLVING NEEDED
                      userProvider.updateTrees(); 
                    }
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  tree.isBought ? Icons.check : Icons.add,
                  color: tree.isBought ? Colors.green : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}