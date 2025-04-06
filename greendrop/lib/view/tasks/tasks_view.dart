import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/model/task.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/tasks/tasks_card.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
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
      dropletReward: 3,
      creationDate: DateTime.now(),
    ),
    Task(
      id: 3,
      description: "Reduce food waste",
      dropletReward: 1,
      creationDate: DateTime.now(),
    ),
    Task(
      id: 4,
      description: "Use public transportation, walk or ride the bike",
      dropletReward: 2,
      creationDate: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tasks",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the text bold
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return TasksCard(
            task: task,
            onStateChanged: () {
              setState(() {}); // Rebuild the UI when the task state changes
            },
          );
        },
      ),
    );
  }
}