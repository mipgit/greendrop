import 'package:flutter/widgets.dart';
import 'package:greendrop/model/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: 1,
      description: "Recycled",
      dropletReward: 1,
      creationDate: DateTime.now(),
    ),
    Task(
      id: 2,
      description: "Turn off lights when not being used",
      dropletReward: 1,
      creationDate: DateTime.now(),
    ),Task(
      id: 4,
      description: "Use public transportation, walk or ride the bike",
      dropletReward: 2,
      creationDate: DateTime.now(),
    ),
    Task(
      id: 3,
      description: "Reduce food waste",
      dropletReward: 1,
      creationDate: DateTime.now(),
    ),
    
    Task(
      id: 5,
      description: "Volunteer for community clean-ups",
      dropletReward: 3,
      creationDate: DateTime.now(),
    ),
  ];

  List<Task> get tasks => _tasks;

  void completeTask(int taskId) {
    final task = _tasks.firstWhere((task) => task.id == taskId);
    task.completeTask();
    notifyListeners();
  }

  void unCompleteTask(int taskId) {
    final task = _tasks.firstWhere((task) => task.id == taskId);
    task.unCompleteTask();
    notifyListeners();
  }
}