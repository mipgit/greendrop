import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/tasks/tasks_card.dart';

import 'package:greendrop/view/tasks/create_task_view.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {

    //avoid the bottom nav bar
    final double bottomNavBarHeightPadding = 100.0; 


    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userTasks = userProvider.userTasks;
          final timeLeft = userProvider.timeUntilNextReset;

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
                child: Text(
                  'Tasks refresh in: ${formatDuration(timeLeft)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomNavBarHeightPadding), 
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final personalizedTasksCount = userProvider.userTasks.where((t) => t.isPersonalized).length;
            final isLimitReached = personalizedTasksCount >= 3;

            return FloatingActionButton(
              onPressed: isLimitReached
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: SizedBox(
                            height: 25, 
                            child: Center(
                              child: Text("You have reached the limit of 3 personalized tasks.",),
                            ),
                          ), 
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CreateTaskView();
                        },
                      );
                    },
              backgroundColor: isLimitReached ? Colors.grey : Colors.lightGreen,
              child: const Icon(Icons.add),
            );
          },
        ),
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