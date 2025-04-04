import 'package:flutter/material.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/user_provider.dart';



class TreeProvider with ChangeNotifier {

  Tree tree;
  //User user;

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
    } else {
      print("Not enough droplets to water the tree."); //isto é meio desnessesário agora não?
    }

  }


}