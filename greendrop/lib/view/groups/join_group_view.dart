import 'package:flutter/material.dart';

class JoinGroupView extends StatefulWidget {
  const JoinGroupView({super.key});

  @override
  State<JoinGroupView> createState() => _JoinGroupViewState();
}

class _JoinGroupViewState extends State<JoinGroupView> {
  final TextEditingController _groupCodeController = TextEditingController();

  @override
  void dispose() {
    _groupCodeController.dispose();
    super.dispose();
  }

  void _joinGroup(BuildContext context) {
    String groupCode = _groupCodeController.text.trim();
    if (groupCode.isNotEmpty) {
      // TODO: Implement the logic to join the group
      print('Attempting to join group with code: $groupCode');
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _groupCodeController,
          decoration: const InputDecoration(
            labelText: 'Group Code',
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
              onPressed: () => _joinGroup(context),
              child: const Text('Join'),
            ),
          ],
        ),
      ],
    );
  }
}