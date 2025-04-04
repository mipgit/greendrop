import 'package:greendrop/model/level.dart';

class Tree {

  Tree({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    //required this.user,
    required this.levels,
    required this.price,
    this.curLevel = 0, //para ser mais facil lidar c/ lista de levels
    this.dropletsUsed = 0,
    this.isBought = false
  });


  final int id;
  String name;
  final String type;
  final String description;
  //final String user;
  final List<Level> levels;
  int curLevel;
  int dropletsUsed;
  final int price;
  bool isBought;



  void waterTree() {
    dropletsUsed ++;
    _checkLevelProgression();
  }

  void _checkLevelProgression() {
    if (curLevel < levels.length && dropletsUsed >= levels[curLevel].requiredDroplets) {
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