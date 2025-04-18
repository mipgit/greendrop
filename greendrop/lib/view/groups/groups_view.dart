import 'package:flutter/material.dart';
import 'package:greendrop/view/groups/create_group_view.dart';
import 'package:greendrop/view/groups/join_group_view.dart';

class GroupsView extends StatelessWidget {
  const GroupsView({super.key});

  void _showAddChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Create Group'),
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateGroup(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Join Group'),
              onTap: () {
                Navigator.pop(context);
                _navigateToJoinGroup(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToCreateGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }

  void _navigateToJoinGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinGroupScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your Groups will appear here',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddChatOptions(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}