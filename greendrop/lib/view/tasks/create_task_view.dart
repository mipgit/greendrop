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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final description = _descriptionController.text.trim();

    final personalizedTasksCount = userProvider.userTasks.where((t) => t.id.startsWith('user_')).length;
    if (personalizedTasksCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can only create up to 3 personalized tasks."),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    if (description.isNotEmpty) {
      final newTask = Task(
        id: 'user_${DateTime.now().toString()}', // Prefix in ID to identify personalized tasks
        description: description,
        dropletReward: 1,
        creationDate: DateTime.now(),
      );

      Provider.of<UserProvider>(context, listen: false).addTask(newTask);
      Navigator.pop(context); // Go back to the tasks page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _createTask(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
              ),
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}