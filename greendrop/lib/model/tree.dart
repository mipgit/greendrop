import 'package:greendrop/model/level.dart';

class Tree {

  Tree({
    required this.id,
    required this.name,
    required this.species,
    required this.description,
    required this.levels,
    required this.price,
    this.curLevel = 0, //para ser mais facil lidar c/ lista de levels
    this.dropletsUsed = 0,
    //this.isBought = false
  });


  final int id;
  String name;
  final String species;
  final String description;
  final List<Level> levels;
  int curLevel;
  int dropletsUsed;
  final int price;
  //bool isBought;



  void waterTree() {
    dropletsUsed ++;
    _checkLevelUp();
  }

  void _checkLevelUp() {
    if (curLevel < levels.length-1 && dropletsUsed >= levels[curLevel+1].requiredDroplets) {
      curLevel++;
    }
  }


  Level? getCurrentLevel() {
    if (curLevel < levels.length) {
      return levels[curLevel];
    }
    return null;
  }

}