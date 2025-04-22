import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart';

class CreateTaskView extends StatefulWidget {
  const CreateTaskView({super.key});

  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTask(BuildContext context) {
    final description = _descriptionController.text.trim();

    if (description.isNotEmpty) {

      // unique ID using UUID package or Firebase
      final taskId = FirebaseFirestore.instance.collection('tasks').doc().id;

      final newTask = Task(
        id: taskId,
        description: description,
        dropletReward: 1,
        creationDate: DateTime.now(),
        isCompleted: false,
        isPersonalized: true,
      );

      Provider.of<UserProvider>(context, listen: false).addPersonalizedTask(newTask);

      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Task'),
      content: TextField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          labelText: 'Task Description',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog without creating a task
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _createTask(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}