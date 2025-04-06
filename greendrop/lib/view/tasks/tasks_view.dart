import 'package:flutter/material.dart';
import 'package:greendrop/view-model/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/tasks/tasks_card.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

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
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
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