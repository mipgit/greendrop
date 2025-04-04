import 'package:flutter/material.dart';
import 'package:greendrop/view-model/tree_provider.dart';
import 'package:provider/provider.dart';

class TreeHomeCard extends StatelessWidget {
  TreeHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TreeProvider>(context);
    final tree = prov.tree;
    final curLevel =
        tree.curLevel < tree.levels.length ? tree.levels[tree.curLevel] : null;

    return Card(
      elevation: 3,
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
            Text('Species: ${tree.species}', 
                style: TextStyle(fontStyle: FontStyle.italic)),
            SizedBox(height: 8),
            Text('Droplets Used: ${tree.dropletsUsed}'),
            if (curLevel != null)
              Container(
                height: 330,
                width: double.infinity,
                padding: EdgeInsets.all(4),
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
