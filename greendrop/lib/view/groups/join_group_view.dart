import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/services/group_service.dart';

class JoinGroupView extends StatefulWidget {
  const JoinGroupView({super.key});

  @override
  State<JoinGroupView> createState() => _JoinGroupViewState();
}

class _JoinGroupViewState extends State<JoinGroupView> {
  final TextEditingController _groupIdController = TextEditingController();

  void _joinGroup(BuildContext context) {
    if (_groupIdController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attempting to join group: ${_groupIdController.text.trim()}')),
      );
      Navigator.pop(context);
      Provider.of<GroupService>(context, listen: false).fetchUserGroups(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group ID.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Group'),
      content: TextField(
        controller: _groupIdController,
        decoration: const InputDecoration(
          labelText: 'Enter Group ID',
          border: OutlineInputBorder(),
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
          onPressed: () => _joinGroup(context),
          child: const Text('Join'),
        ),
      ],
    );
  }
}