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
  
  // Mock data for template tasks categories
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Waste Reduction',
      'tasks': [
        'Useed a reusable water bottle instead of plastic bottles',
        'Brought your own shopping bags to the grocery store',
        'Avoided single-use plastic utensils'
      ]
    },
    {
      'name': 'Energy Conservation',
      'tasks': [
        'Turned off lights when leaving a room',
        'Unpluged electronic devices when not in use',
        'Used natural lighting instead of artificial when possible'
      ]
    },
    {
      'name': 'Sustainable Transport',
      'tasks': [
        'Walked or cycled for short trips instead of driving',
        'Used public transportation',
        'Carpooled with colleagues or friends'
      ]
    },
    {
      'name': 'Water Conservation',
      'tasks': [
        'Took shorter shower (under 5 minutes)',
        'Turned off water while brushing teeth',
        'Checked for and fixed any leaky faucets'
      ]
    }
  ];

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
        content: Text('Added task: $taskDescription'),
        duration: const Duration(seconds: 2),
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
                          category['name'],
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
                  ...List.generate(
                    (category['tasks'] as List).length,
                    (taskIndex) {
                      final task = category['tasks'][taskIndex];
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 16, right: 8),
                        title: Text(task),
                        onTap: () => _selectTask(context, task),
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