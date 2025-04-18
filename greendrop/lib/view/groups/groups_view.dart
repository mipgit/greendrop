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
                _showCreateGroupDialog(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Join Group'),
              onTap: () {
                Navigator.pop(context); 
                _showJoinGroupDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Group'),
          content: const CreateGroupView(),
        );
      },
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Group'),
          content: const JoinGroupView(),
        );
      },
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