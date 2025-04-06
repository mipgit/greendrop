import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart';

class TasksCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onStateChanged;

  const TasksCard({super.key, required this.task, required this.onStateChanged});

  void _toggleTaskCompletion(BuildContext context, Task task) {
    //final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!task.isCompleted) {
      userProvider.completeTask(task);
      userProvider.addDroplets(task.dropletReward);
    } else {
      userProvider.unCompleteTask(task);
      userProvider.takeDroplets(task.dropletReward);
    }

    if (onStateChanged != null) {
      onStateChanged!(); // Call the callback if it's provided
    }
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context); 

    // Find the current state of this specific task from the user's task list
    final currentTaskState = userProvider.userTasks.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task, // Fallback to the passed task if not found (shouldn't happen)
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Checkbox(
          value: currentTaskState.isCompleted,
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