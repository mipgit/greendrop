import 'package:flutter/material.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/user_provider.dart';



class TreeProvider with ChangeNotifier {

  Tree tree;

  TreeProvider(this.tree);

  String get name => tree.name;
  String get description => tree.description;
  int get curLevel => tree.curLevel;
  List<Level> get levels => tree.levels;
  int get dropletsUsed => tree.dropletsUsed;
  Level? getCurrentLevel() => tree.getCurrentLevel();

  void waterTree(UserProvider userProvider) {
    if (userProvider.user.droplets > 0) { 
      tree.waterTree();
      userProvider.takeDroplets(1);
      notifyListeners();
      userProvider.updateUserTreeInFirestore(tree);
    } else {
      print("Not enough droplets to water the tree."); //isto é meio desnecessário agora não?
    }

  }

  // method to get the droplets needed for the next level
  int getDropletsNeededForNextLevel() {
    final currentLevelIndex = tree.curLevel;
    if (currentLevelIndex < tree.levels.length - 1) {
      return tree.levels[currentLevelIndex + 1].requiredDroplets;
    }
    // if the tree is at the maximum level, it doesn't need more droplets
    return 0;
  }

}