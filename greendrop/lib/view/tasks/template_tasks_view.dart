import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view-model/user_provider.dart';

class TemplateTasksView extends StatefulWidget {
  const TemplateTasksView({super.key});

  @override
  State<TemplateTasksView> createState() => _TemplateTasksViewState();
}

class _TemplateTasksViewState extends State<TemplateTasksView> {
  // Track which category is expanded
  int? _expandedCategoryIndex;
  

  final List<String> _categories = [
    'Waste Reduction',
    'Sustainable Transport',
    'Energy Conservation',
    'Water Conservation',
    'Community Service',
  ];


  Future<List<String>> _getTasksForCategory(String category) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final curUserTasks = userProvider.userTasks;
    //final curTaskDescription = curUserTasks

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('tasks')
          .where('category', isEqualTo: category)
          .limit(2)
          .get();

      final availableTasks = docRef.docs
          .map((doc) => doc.data()['description'] as String)
          .where((id) => !curUserTasks.any((task) => task.description == id))
          .toList();

      return availableTasks;
    } catch (e) {
      print('Error fetching tasks for category $category: $e');
      return [];
    }  
  }


  void _toggleCategory(int index) {
    setState(() {
      if (_expandedCategoryIndex == index) {
        _expandedCategoryIndex = null; // Collapse if already expanded
      } else {
        _expandedCategoryIndex = index; // Expand the selected category
      }
    });
  }

  void _selectTask(BuildContext context, String taskDescription) {
    // Generate a unique ID for the task
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();

    final newTask = Task(
      id: taskId,
      description: taskDescription,
      dropletReward: 1,
      creationDate: DateTime.now(),
      isCompleted: false,
      isPersonalized: true,
    );

    Provider.of<UserProvider>(context, listen: false).addPersonalizedTask(newTask);

    // Close the dialog
    Navigator.of(context).pop();
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SizedBox(
          height: 25,
          child: Center(
            child: Text('Added task: $taskDescription'),
          ),
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Task Template'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isExpanded = _expandedCategoryIndex == index;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header with arrow
                InkWell(
                  onTap: () => _toggleCategory(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider below category header
                const Divider(height: 1),
                // Tasks for the expanded category
                if (isExpanded)
                FutureBuilder<List<String>>(
                  future: _getTasksForCategory(category),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const ListTile(
                        title: Text('No more available tasks in this category'),
                      );
                    }
                    return Column(
                      children: snapshot.data!.map((taskDescription) => ListTile(
                        contentPadding: const EdgeInsets.only(left: 16, right: 8),
                        title: Text(taskDescription),
                        onTap: () => _selectTask(context, taskDescription),
                      )).toList(),
                    );
                  },
                ),
                if (index < _categories.length - 1) const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}