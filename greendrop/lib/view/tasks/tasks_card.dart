import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/task_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';

class TasksCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onStateChanged;

  const TasksCard({super.key, required this.task, required this.onStateChanged});

  void _toggleTaskCompletion(BuildContext context, Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!task.isCompleted) {
      taskProvider.completeTask(task.id);
      userProvider.addDroplets(task.dropletReward);
    } else {
      taskProvider.unCompleteTask(task.id);
      userProvider.takeDroplets(task.dropletReward);
    }

    if (onStateChanged != null) {
      onStateChanged!(); // Call the callback if it's provided
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => _toggleTaskCompletion(context, task),
        ),
        title: Text(task.description),
        subtitle: Text(
          "Reward: ${task.dropletReward} droplets",
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}