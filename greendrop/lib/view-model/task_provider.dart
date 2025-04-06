import 'package:flutter/widgets.dart';
import 'package:greendrop/model/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _allAvailableTasks = [
    Task(
      id: 1,
      description: "Recycled",
      dropletReward: 1,
      creationDate: DateTime.now(),
    ),
    Task(
      id: 2,
      description: "Turned off lights when not being used",
      dropletReward: 1,
      creationDate: DateTime.now(),
    ),Task(
      id: 4,
      description: "Used public transportation, walked or rode the bike",
      dropletReward: 2,
      creationDate: DateTime.now(),
    ),
    Task(
      id: 3,
      description: "Reduced food waste",
      dropletReward: 1,
      creationDate: DateTime.now(),
    ),
    
    Task(
      id: 5,
      description: "Volunteered for community clean-ups",
      dropletReward: 3,
      creationDate: DateTime.now(),
    ),
  ];

  List<Task> get allAvailableTasks => _allAvailableTasks;

}