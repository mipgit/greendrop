import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/tasks/tasks_card.dart';

import 'package:greendrop/view/tasks/create_task_view.dart';
import 'package:greendrop/view/tasks/template_tasks_view.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  void _showAddTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create Personalized Task'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CreateTaskView(); // Show the existing CreateTaskView
                  },
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.format_list_bulleted),
              title: const Text('Create Task with Template'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const TemplateTasksView(); // Show our new TemplateTasksView
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showTasksGuide (BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Task's Guide"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('You can create, delete or reorder tasks from this page. \n'),
              Text.rich(TextSpan(
                children: [
                  TextSpan(text: '• To '),
                  TextSpan(text: 'create a task', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' , click the "+" button at the bottom right corner. \n'),
                ],
              )),
              Text.rich(TextSpan(
                children: [
                  TextSpan(text: '• To '),
                  TextSpan(text: 'delete a personalised task', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' , double tap the task card. \n'),
                ],
              )),
              Text.rich(TextSpan(
                children: [
                  TextSpan(text: '• To '),
                  TextSpan(text: 'reorder tasks', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' , long press and drag the task card to your desired position. \n'),
                ],
              )),
              Text.rich(TextSpan(
                children: [
                  TextSpan(text: 'Note:', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' tasks have '),
                  TextSpan(text: 'different colours', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '! Given daily tasks are green and personalized tasks are grey.'),
                ],
              )),
            ],
          ),
          
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    //avoid the bottom nav bar
    final double bottomNavBarHeightPadding = 100.0; 


    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userTasks = userProvider.userTasks;
          //final timeLeft = userProvider.timeUntilNextReset;

          if (userTasks.isEmpty) {
            return Padding( 
              padding: EdgeInsets.only(bottom: bottomNavBarHeightPadding), 
              child: Center(
                child:Text("No tasks available at the moment.", style: TextStyle(fontSize: 14.0),),
              ),
            );  
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    ValueListenableBuilder<Duration>(
                      valueListenable: context.read<UserProvider>().countdownNotifier,
                      builder: (context, duration, child) {
                        return Text(
                          'Tasks refresh in: ${formatDuration(duration)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ReorderableListView.builder(
                  padding: EdgeInsets.only(bottom: bottomNavBarHeightPadding + 90),
                  itemCount: userTasks.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    userProvider.reorderTasks(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final task = userTasks[index];
                    return TasksCard(
                      key: ValueKey(task.id), // Key is required for reordering
                      task: task,
                      onStateChanged: () {},
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: bottomNavBarHeightPadding + 65, 
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Material(
                elevation: 2,
                color: null,
                borderRadius: BorderRadius.circular(100),
                child: IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.grey),
                  tooltip: 'Help',
                  onPressed: () => _showTasksGuide(context),
                )
                
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: bottomNavBarHeightPadding,
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final personalizedTasksCount = userProvider.userTasks
                    .where((t) => t.isPersonalized).length;
                final isLimitReached = personalizedTasksCount >= 3;

                return FloatingActionButton(
                  onPressed: () {
                    if (isLimitReached) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: SizedBox(
                            height: 25,
                            child: Center(
                              child: Text("You have reached the limit of 3 personalized tasks."),
                            ),
                          ),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      _showAddTaskOptions(context);
                    }
                  },
                  backgroundColor: isLimitReached ? Colors.grey : Colors.lightGreen,
                  child: const Icon(Icons.add),
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '$hours hours, $minutes minutes, $seconds seconds';
  }

}