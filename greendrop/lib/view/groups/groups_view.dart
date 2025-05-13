import 'package:flutter/material.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:greendrop/services/group_service.dart';
import 'package:greendrop/view/groups/create_group_view.dart';
import 'package:greendrop/view/groups/join_group_view.dart';
import 'package:greendrop/view/groups/chat_view.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialGroups();
    });
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
    final TextEditingController groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateGroupView(
          groupNameController: groupNameController,
          onCreatePressed: (localContext, groupName) =>
              _handleCreateGroup(localContext, groupName),
        );
      },
    );
  }

  Future<void> _handleCreateGroup(BuildContext context, String groupName) async {
    if (groupName.isNotEmpty) {
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      if (authService.isGuest) {
        try {
          await authService.signInAnonymously();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SizedBox(
                height: 25, 
                child: Center(
                  child: Text('Failed to sign in as guest: $e'),
                ),
              ),              
              behavior: SnackBarBehavior.floating,
            ),
          );
          return; // Don't proceed with group creation if guest sign-in fails
        }
      }

      try {
        final groupService = Provider.of<GroupService>(context, listen: false);
        final newGroup = await groupService.createGroup(context, groupName);
        if (newGroup != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: SizedBox(
                height: 25, 
                child: Center(
                  child: Text('Group created successfully!'),
                ),
              ),   
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: SizedBox(
                height: 25, 
                child: Center(
                  child: Text('Failed to create group.'),
                ),
              ),   
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: 25, 
              child: Center(
                child: Text('Error creating group: $e'),
              ),
            ),   
            behavior: SnackBarBehavior.floating,
          ),
        );
        print('Error creating group: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SizedBox(
            height: 25, 
            child: Center(
              child: Text('Group name cannot be empty'),
            ),
          ),   
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }



  void _showJoinGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const JoinGroupView();
      },
    ).then((joinedSuccessfully) {
      if (joinedSuccessfully == true) {
        _loadInitialGroups();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    //avoid the bottom nav bar
    final double bottomNavBarHeightPadding = 100.0; 

    return Scaffold(
        body: Padding( 
        padding: EdgeInsets.only(bottom: bottomNavBarHeightPadding), 
          child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Consumer<GroupService>(
                builder: (context, groupService, child) {
                  final groups = groupService.groups;
                  return groups.isEmpty
                      ? const Center(
                        child: Text(
                          'Your groups will appear here.',
                          style: TextStyle(fontSize: 14.0),
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
                                  builder:
                                      (context) => ChatView(
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
        ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomNavBarHeightPadding), 
        child: Consumer<AuthenticationService>(
          builder: (context, authService, child) {
            if (authService.isGuest) {
              return FloatingActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: SizedBox(
                        height: 25, 
                        child: Center(
                          child: Text('Sign in to use groups.'),
                        ),
                      ),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,  
                    ),
                  );
                },
                backgroundColor: Colors.grey,
                child: const Icon(Icons.add), // if guest, can't create groups
              );
            }
            return FloatingActionButton(
              onPressed: () {
                _showAddChatOptions(context);
              },
              backgroundColor: Colors.lightGreen, // pus igual às tasks
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}