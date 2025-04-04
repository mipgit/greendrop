import 'package:flutter/material.dart';
import 'package:greendrop/view-model/tree_provider.dart';
import 'package:provider/provider.dart';

class TreeHomeCard extends StatelessWidget {
  final VoidCallback onWater;

  TreeHomeCard({required this.onWater});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TreeProvider>(context);
    final tree = prov.tree;
    final curLevel =
        tree.curLevel < tree.levels.length ? tree.levels[tree.curLevel] : null;

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tree.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(tree.description),
            SizedBox(height: 8),
            Text('Type: ${tree.type}'),
            SizedBox(height: 8),
            Text('Droplets Used: ${tree.dropletsUsed}'),
            if (curLevel != null)
              Container(
                height: 350,
                width: double.infinity,
                padding: EdgeInsets.all(10),
                //decoration: BoxDecoration(color: Colors.grey[200]),
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 150,
                  child: Image.asset(
                    curLevel.levelPicture,
                    fit: BoxFit.contain, 
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
