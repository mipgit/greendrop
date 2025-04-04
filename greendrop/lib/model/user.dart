import 'package:greendrop/model/task.dart';
import 'package:greendrop/model/tree.dart';

class User {

  User({
    required this.id,
    required this.username,
    required this.email,
    //required this.profilePicture,
    required this.trees,
    required this.tasks,
    this.droplets = 0

  });


  final int id;
  final String username;
  final String email;
  //final String profilePicture;
  List<Tree> trees;
  List<Task> tasks;
  int droplets;


  void addDroplets(int amount) {
    droplets += amount;
  }
 
  void takeDroplets(int amount) {
    droplets -= amount;
  }

  void addTree(Tree tree) {
    trees.add(tree);
  }


  bool buyTree(Tree tree) {
    if (droplets >= tree.price && tree.isBought == false) {
      tree.isBought = true;
      trees.add(tree);
      droplets -= tree.price;
      return true;
    }
    return false;
  }


  void completeTask(Task task) {
    if (!task.isCompleted) {
      task.completeTask();
      addDroplets(task.getReward());
    }
  }

  void unCompleteTask(Task task) {
    if (task.isCompleted) {
      task.unCompleteTask();
      takeDroplets(task.getReward());
    }
  }

}
