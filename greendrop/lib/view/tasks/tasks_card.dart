import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

class TasksCard extends StatelessWidget {
  final Task task;
  final VoidCallback onStateChanged; // Callback to notify parent of state change

  const TasksCard({super.key, required this.task, required this.onStateChanged});

  void _toggleTaskCompletion(BuildContext context, Task task) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.user.isTaskCompleted(task.id)) {
      userProvider.user.completeTask(task.id);
      userProvider.addDroplets(task.dropletReward);
    } else {
      userProvider.user.unCompleteTask(task.id);
      userProvider.takeDroplets(task.dropletReward);
    }

    onStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isCompleted = userProvider.user.isTaskCompleted(task.id); // Check if the task is completed

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted, // Reflect the completion state
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