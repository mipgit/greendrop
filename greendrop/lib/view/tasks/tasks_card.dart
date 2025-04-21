import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/tasks/droplet_reward_badge.dart';

class TasksCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onStateChanged;

  const TasksCard({super.key, required this.task, required this.onStateChanged});

  void _toggleTaskCompletion(BuildContext context, Task task) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!task.isCompleted) {
      userProvider.completeTask(task);
    }  else {
      userProvider.unCompleteTask(task);
    }
    
    if (onStateChanged != null) {
      onStateChanged!(); // Call the callback if it's provided
    }
  }


  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).removePersonalizedTask(task);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);

    // Set the background color based on whether the task is personalized
    final backgroundColor = task.isPersonalized
        ? const Color.fromARGB(255, 239, 243, 234)
        : const Color.fromARGB(255, 220, 236, 202);


    // Find the current state of this specific task from the user's task list
    final currentTaskState = userProvider.userTasks.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task, // Fallback to the passed task if not found (shouldn't happen)
    );


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.dropletReward > 0)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: DropletRewardBadge(reward: task.dropletReward),
          ),

          GestureDetector(
            onDoubleTap: () {
              if (task.isPersonalized) {
                _showDeleteDialog(context, task);
              }
            },
            child: Card(
              color: backgroundColor,
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        task.description,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  Checkbox(
                    value: currentTaskState.isCompleted,
                    onChanged: (_) => _toggleTaskCompletion(context, task),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}