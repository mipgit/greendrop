import 'package:flutter/material.dart';

class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key});

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _createGroup(BuildContext context) {
    String groupName = _groupNameController.text.trim();
    if (groupName.isNotEmpty) {
      // TODO: Implement the logic to create the group
      print('Creating group with name: $groupName');
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name cannot be empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () => _createGroup(context),
              child: const Text('Create'),
            ),
          ],
        ),
      ],
    );
  }
}