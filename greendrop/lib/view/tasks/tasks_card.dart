import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:greendrop/view-model/group_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart';

class TasksCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onStateChanged;
  final bool isGroupTask;

  const TasksCard({super.key, required this.task, required this.onStateChanged, this.isGroupTask = false});

  void _toggleTaskCompletion(BuildContext context, Task task) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (isGroupTask) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final userId = userProvider.user.id;
      final isCompleted = groupProvider.hasUserCompleted(userId);

      if (!isCompleted) {
        groupProvider.completeGroupTask(context, userId);
      } else {
        groupProvider.unCompleteGroupTask(context, userId);
      }
    } else {
      if (!task.isCompleted) {
        userProvider.completeTask(task);
      } else {
        userProvider.unCompleteTask(task);
      }
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
    GroupProvider? groupProvider;
    if (isGroupTask) {
      groupProvider = Provider.of<GroupProvider>(context);
    }

    final backgroundColor = isGroupTask
      ? const Color.fromARGB(255, 227, 241, 234)
      : (task.isPersonalized
          ? const Color.fromARGB(255, 239, 243, 234)
          : const Color.fromARGB(255, 220, 236, 202));


    final bool isCompleted = isGroupTask
      ? groupProvider!.hasUserCompleted(userProvider.user.id)
      : userProvider.userTasks.firstWhere(
          (t) => t.id == task.id,
          orElse: () => task,
        ).isCompleted;


    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () {
            if (task.isPersonalized) {
              _showDeleteDialog(context, task);
            }
          },
          child: Card(
            color: backgroundColor,
            margin: const EdgeInsets.only(
              top: 24.0, left: 16.0, right: 16.0, bottom: 8.0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: isCompleted,
                    onChanged: (_) => _toggleTaskCompletion(context, task),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            
            ),
            child: Row(
              children: [
                Text(
                  '${task.dropletReward}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.water_drop,
                  size: 16.0,
                  color: Colors.green[700],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}