import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/tasks/tasks_card.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tasks to do today :)",
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userTasks = userProvider.userTasks;

          return ListView.builder(
            itemCount: userTasks.length,
            itemBuilder: (context, index) {
              final task = userTasks[index];
              return TasksCard(
                task: task,
                onStateChanged: () {
                },
              );
            },
          );
        },
      ),
    );
  }
}