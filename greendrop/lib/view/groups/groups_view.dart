import 'package:flutter/material.dart';
import 'package:greendrop/services/group_service.dart';
import 'package:greendrop/view/groups/create_group_view.dart';
import 'package:greendrop/view/groups/join_group_view.dart';
import 'package:greendrop/view/groups/group_chat_view.dart';
import 'package:provider/provider.dart';

class GroupsView extends StatefulWidget {
  const GroupsView({super.key});

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialGroups();
  }

  Future<void> _loadInitialGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final groupService = Provider.of<GroupService>(context, listen: false);
      await groupService.fetchUserGroups(context);
      setState(() {
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
        return CreateGroupView(
          groupNameController: _groupNameController,
          onCreatePressed: (localContext, groupName) =>
              _handleCreateGroup(localContext, groupName),
        );
      },
    );
  }

  Future<void> _handleCreateGroup(BuildContext context, String groupName) async {
    if (groupName.isNotEmpty) {
      try {
        final groupService = Provider.of<GroupService>(context, listen: false);
        final newGroup = await groupService.createGroup(context, groupName);
        if (newGroup != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group created successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create group.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
        print('Error creating group: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name cannot be empty')),
      );
    }
  }

  void _showJoinGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const JoinGroupView();
      },
    ).then((_) {
      _handleJoinGroup(context);
    });
  }

  Future<void> _handleJoinGroup(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joining a group is not yet implemented.')),
    );
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
              : Consumer<GroupService>(
                  builder: (context, groupService, child) {
                    final groups = groupService.groups;
                    return groups.isEmpty
                        ? const Center(
                            child: Text(
                              'Your Groups will appear here',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          )
                        : ListView.builder(
                            itemCount: groups.length,
                            itemBuilder: (context, index) {
                              final group = groups[index];
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.group),
                                ),
                                title: Text(group.name),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatView(
                                        groupId: group.id,
                                        groupName: group.name,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
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