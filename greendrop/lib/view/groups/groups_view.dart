import 'package:flutter/material.dart';
import 'package:greendrop/model/group.dart'; 

class GroupsView extends StatefulWidget {
  const GroupsView({super.key});

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  final List<Group> _groups = [];

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
    final TextEditingController _groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Group'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
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
              onPressed: () {
                String groupName = _groupNameController.text.trim();
                if (groupName.isNotEmpty) {
                  _createGroup(context, groupName);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group name cannot be empty')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _createGroup(BuildContext context, String groupName) {
    // In a real application, you would:
    // 1. Get the current user's ID.
    // 2. Generate a unique ID for the new group.
    // 3. Create a new Group object using the imported Group class.
    // 4. Save the new group to your database/backend.
    // 5. Update the current user's groupIds list.
    // 6. Fetch the updated list of groups (or the new group) and update the UI.

    // For this example, we'll simulate creating a group locally:
    final newGroupId = DateTime.now().millisecondsSinceEpoch.toString(); // Simple unique ID
    const creatorId = 'user123'; // Replace with the actual current user's ID
    final newGroup = Group(
      id: newGroupId,
      name: groupName,
      creatorId: creatorId,
      creationDate: DateTime.now(),
      memberIds: [creatorId], // Add the creator as the first member
    );

    setState(() {
      _groups.add(newGroup); // Update the local UI list
    });

    // You would also need to update the user's groupIds:
    // (This depends on how you manage your user data)
    // Example (if you have access to a User object):
    // currentUser.joinGroup(newGroupId);
    // Also, you'd likely want to persist this change to the user in your database.

    print('Created group: ${newGroup.name} with ID: ${newGroup.id}');
  }

  void _showJoinGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Join Group'),
          content: Text('Join group functionality will be implemented here.'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: _groups.isEmpty
          ? const Center(
              child: Text(
                'Your Groups will appear here',
                style: TextStyle(fontSize: 16.0),
              ),
            )
          : ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.group),
                  ),
                  title: Text(group.name),
                  // You can add onTap functionality to navigate to the group chat
                );
              },
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