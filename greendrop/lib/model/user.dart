import 'package:flutter/material.dart';

class User extends ChangeNotifier {

  User({
    required this.id,
    required this.username,
    required this.email,
    //required this.profilePicture,
    required this.ownedTrees,
    required this.tasks,
    this.droplets = 0

  });


  final int id;
  final String username;
  final String email;
  //final String profilePicture;
  List<int> ownedTrees;
  List<int> tasks;
  int droplets;


  void addDroplets(int amount) {
    addDroplets(amount);
    notifyListeners();
  }

  void takeDroplets(int amount) {
    takeDroplets(amount);
    notifyListeners();
  }

  void completeTask(int taskId) {
    if (!tasks.contains(taskId)) {
      tasks.add(taskId);
      notifyListeners();
    }
  }

  void unCompleteTask(int taskId) {
    tasks.remove(taskId);
    notifyListeners();
  }

  bool isTaskCompleted(int taskId) {
    return tasks.contains(taskId);
  }

}
