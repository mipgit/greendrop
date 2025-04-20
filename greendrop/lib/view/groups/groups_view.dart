// lib/views/groups_view.dart
import 'package:flutter/material.dart';
import 'package:greendrop/model/group.dart';
import 'package:greendrop/services/group_service.dart';
import 'package:provider/provider.dart';

class GroupsView extends StatefulWidget {
  const GroupsView({super.key});

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  List<Group> _groups = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final groupService = Provider.of<GroupService>(context, listen: false);
      final groups = await groupService.fetchUserGroups(context);
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load groups: $e';
        _isLoading = false;
      });
      print('Error loading groups: $e');
    }
  }

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
              onPressed: () => _createGroup(context, _groupNameController.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createGroup(BuildContext context, String groupName) async {
    print('Attempting to create group with name: $groupName');
    if (groupName.isNotEmpty) {
      try {
        final groupService = Provider.of<GroupService>(context, listen: false);
        print('Calling groupService.createGroup...');
        final newGroup = await groupService.createGroup(context, groupName);
        print('groupService.createGroup returned: $newGroup');
        if (newGroup != null) {
          setState(() {
            _groups.add(newGroup);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group created successfully!')),
          );
          print('Calling Navigator.pop(context) on success');
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create group.')),
          );
          print('Group creation failed, NOT calling Navigator.pop(context)');
          // Optionally, you might want to log the reason for failure here
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
        print('Error creating group: $e, NOT calling Navigator.pop(context)');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name cannot be empty')),
      );
      print('Group name empty, NOT calling Navigator.pop(context)');
    }
  }

  void _showJoinGroupDialog(BuildContext context) {
    final TextEditingController _groupIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Group'),
          content: TextField(
            controller: _groupIdController,
            decoration: const InputDecoration(
              labelText: 'Group ID',
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
              onPressed: () => _joinGroup(context, _groupIdController.text.trim()),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _joinGroup(BuildContext context, String groupId) async {
    if (groupId.isNotEmpty) {
      try {
        final groupService = Provider.of<GroupService>(context, listen: false);
        final success = await groupService.joinGroup(context, groupId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully joined group: $groupId')),
          );
          _loadGroups(); // Reload to show the updated list
          Navigator.pop(context); // Dismiss the join group dialog
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to join group with ID: $groupId. Please check the ID.')),
          );
          // Optionally, don't pop the dialog to allow the user to retry
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining group: $e')),
        );
        print('Error joining group: $e');
        // Optionally, don't pop the dialog to allow the user to retry
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group ID.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _groups.isEmpty
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