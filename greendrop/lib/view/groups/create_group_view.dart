import 'package:flutter/material.dart';

class CreateGroupView extends StatefulWidget {
  final TextEditingController groupNameController;
  final Function(BuildContext, String) onCreatePressed;

  const CreateGroupView({
    super.key,
    required this.groupNameController,
    required this.onCreatePressed,
  });

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Group'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: widget.groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () =>
              widget.onCreatePressed(context, widget.groupNameController.text.trim()),
          child: const Text('Create'),
        ),
      ],
    );
  }
}