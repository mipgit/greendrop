import 'package:flutter/material.dart';

class TaskListItem extends StatelessWidget {
  final String task;
  final bool completed;
  final ValueChanged<bool?>? onChanged;

  const TaskListItem({Key? key, required this.task, required this.completed, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade200, // Softer background color
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)), // Rounded corners for checkbox
              value: completed,
              onChanged: onChanged,
              activeColor: Colors.green.shade700,
              checkColor: Colors.white,
            ),
          ),
          title: Text(
            task,
            style: TextStyle(
              color: Colors.green.shade900, // Updated text color
              fontSize: 18.0, // Updated font size
            ),
          ),
        ),
      ),
    );
  }
}