import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/task_provider.dart';
import 'package:greendrop/view-model/tree_provider.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  List<Tree> _userTrees = []; // user's trees
  List<Task> _userTasks = []; // user's tasks
  List<TreeProvider> _treeProviders = []; // list of TreeProviders
  List<TaskProvider> _taskProviders = []; // list of TaskProviders

  User user;

  List<Tree> get userTrees => _userTrees;
    List<Task> get userTasks => _userTasks;
  List<TreeProvider> get treeProviders => _treeProviders;
  List<TaskProvider> get taskProviders => _taskProviders;


  UserProvider(BuildContext context)
    : user = User(
        id: 1,
        username: "johndoe",
        email: "johndoe@email.com",
        ownedTrees: [1],
        ownedTasks: [1,2,3,4],
        droplets: 100,

      ) {
    _initializeUserTrees(context);
    _initializeUserTasks(context);
  }



  void _initializeUserTrees(BuildContext context) {
    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    _userTrees = user.ownedTrees.map((treeId) {
      return gardenProvider.allAvailableTrees.firstWhere(
        (tree) => tree.id == treeId,
        orElse: () => throw StateError('Tree with ID $treeId not found in catalog'),
      );
    }).toList();
    _treeProviders = _userTrees.map((tree) => TreeProvider(tree)).toList();
    notifyListeners();
  }


  // para Cuca/Narciso mudarem/usarem
  void buyTree(BuildContext context, int treeId) {
    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    final treeToBuy = gardenProvider.allAvailableTrees.firstWhere(
      (tree) => tree.id == treeId,
      orElse: () => throw StateError('Tree with ID $treeId not found in catalog'),
    );


    if (user.droplets >= treeToBuy.price && !user.ownedTrees.contains(treeId)) {
      user.takeDroplets(treeToBuy.price);
      user.ownedTrees.add(treeId);
      _initializeUserTrees(context); // Re-fetch and update user's trees
      notifyListeners();
      print('${treeToBuy.name} bought successfully!');
    } else if (user.ownedTrees.contains(treeId)) {
      print('You already own ${treeToBuy.name}.');
    } else {
      print('Not enough droplets to buy ${treeToBuy.name}.');
    }
  }





  //adding methods to update user's info and TreeProviders as needed
  void updateTrees() {
    _treeProviders = _userTrees.map((tree) => TreeProvider(tree)).toList();
    notifyListeners();
  }

  void addDroplets(int amount) {
    user.droplets += amount; //this needs fixing but i dont want to change user class yet
    notifyListeners(); 
  }

  void takeDroplets(int amount) {
    user.droplets -= amount;
    notifyListeners(); 
  }





  void _initializeUserTasks(BuildContext context) {
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    _userTasks = user.ownedTasks.map((taskId) {
      return tasksProvider.allAvailableTasks.firstWhere(
        (task) => task.id == taskId,
        orElse: () => throw StateError('Task with ID $taskId not found'),
      );
    }).toList();
    notifyListeners();
  }



  void completeTask(Task task) {
    if (!_userTasks.any((t) => t.id == task.id)) return; // Ensure task belongs to user
    final index = _userTasks.indexWhere((t) => t.id == task.id);
    if (index != -1 && !_userTasks[index].isCompleted) {
      _userTasks[index].completeTask();
      notifyListeners();
    }
  }

  void unCompleteTask(Task task) {
    if (!_userTasks.any((t) => t.id == task.id)) return; // Ensure task belongs to user
    final index = _userTasks.indexWhere((t) => t.id == task.id);
    if (index != -1 && _userTasks[index].isCompleted) {
      _userTasks[index].unCompleteTask();
      notifyListeners();
    }
  }

  bool isTaskCompleted(int taskId) {
    return _userTasks.any((task) => task.id == taskId && task.isCompleted);
  }

}