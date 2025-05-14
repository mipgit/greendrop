// In view/groups/group_settings_view.dart
 import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:firebase_auth/firebase_auth.dart';
 import 'package:flutter/material.dart';
 import 'package:flutter/services.dart';
 import 'package:provider/provider.dart';
 import 'package:greendrop/services/group_service.dart';

 class GroupSettingsView extends StatefulWidget {
   final String groupId;
   final String groupName;

   const GroupSettingsView({super.key, required this.groupId, required this.groupName});

   @override
   State<GroupSettingsView> createState() => _GroupSettingsViewState();
 }

 class _GroupSettingsViewState extends State<GroupSettingsView> {
   final TextEditingController _bioController = TextEditingController();
   final TextEditingController _groupNameController = TextEditingController();
   String? _groupBio;
   List<String> _memberIds = [];
   bool _isEditingName = false;

   @override
   void initState() {
     super.initState();
     _loadGroupDetails();
     _groupNameController.text = widget.groupName; // Initialize with current name
   }

   Future<void> _loadGroupDetails() async {
     try {
       final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
       if (groupDoc.exists && groupDoc.data() != null) {
         final groupData = groupDoc.data() as Map<String, dynamic>;
         setState(() {
           _groupBio = groupData['bio'] as String?;
           _bioController.text = _groupBio ?? '';
           _memberIds = (groupData['memberIds'] as List<dynamic>?)?.cast<String>() ?? [];
         });
       }
     } catch (e) {
       print('Error loading group details: $e');
     }
   }

   Future<void> _updateGroupBio(String newBio) async {
     try {
       await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({'bio': newBio});
       setState(() {
         _groupBio = newBio;
       });
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Group bio updated!')),
       );
     } catch (e) {
       print('Error updating group bio: $e');
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Failed to update group bio.')),
       );
     }
   }

   Future<void> _updateGroupName(String newName) async {
     if (newName.trim() != widget.groupName.trim()) {
       try {
         await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({'name': newName.trim()});
         setState(() {
           _isEditingName = false;
         });
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Group name updated!')),
         );
         // You might need to update the group name in the ChatView as well
         // Consider using a state management solution for cross-widget updates
       } catch (e) {
         print('Error updating group name: $e');
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Failed to update group name.')),
         );
       }
     } else {
       setState(() {
         _isEditingName = false;
       });
     }
   }

   Future<void> _leaveGroup(BuildContext context) async {
     final userId = FirebaseAuth.instance.currentUser?.email;
     if (userId != null) {
       final groupService = Provider.of<GroupService>(context, listen: false);
       bool left = await groupService.leaveGroup(context, widget.groupId, userId);
       if (left) {
         Navigator.pop(context); // Go back to chat view
         Navigator.pop(context); // Go back to groups list
       }
     }
   }

   void _copyGroupId(BuildContext context) {
     Clipboard.setData(ClipboardData(text: widget.groupId));
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Group ID copied to clipboard!')),
     );
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         leading: IconButton(
           icon: const Icon(Icons.arrow_back),
           onPressed: () => Navigator.pop(context),
         ),
         title: Text(_isEditingName ? 'Edit Group Name' : 'Group Details'),
         actions: [
           if (_isEditingName)
             IconButton(
               icon: const Icon(Icons.save),
               onPressed: () => _updateGroupName(_groupNameController.text),
             ),
           if (!_isEditingName)
             IconButton(
               icon: const Icon(Icons.edit),
               onPressed: () {
                 setState(() {
                   _isEditingName = true;
                 });
               },
             ),
         ],
       ),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: <Widget>[
             const CircleAvatar(
               radius: 50,
               child: Icon(Icons.group, size: 40), // Placeholder
             ),
             const SizedBox(height: 16.0),
             if (_isEditingName)
               TextFormField(
                 controller: _groupNameController,
                 textAlign: TextAlign.center,
                 style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                 decoration: const InputDecoration(
                   border: OutlineInputBorder(),
                 ),
               )
             else
               Text(
                 widget.groupName,
                 style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
               ),
             const SizedBox(height: 8.0),
             GestureDetector(
               onTap: () => _copyGroupId(context),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text(
                     'Group ID: ',
                     style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey),
                   ),
                   Expanded(
                     child: Text(
                       widget.groupId,
                       style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   const SizedBox(width: 4.0),
                   const Icon(Icons.copy, size: 16.0, color: Colors.grey),
                 ],
               ),
             ),
             const SizedBox(height: 16.0),
             const Text(
               'Bio',
               style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 8.0),
             TextFormField(
               controller: _bioController,
               maxLines: 3,
               decoration: const InputDecoration(
                 border: OutlineInputBorder(),
                 hintText: 'Enter group bio...',
               ),
               onChanged: (newBio) {
                 _updateGroupBio(newBio);
               },
             ),
             const SizedBox(height: 20.0),
             const Divider(),
             const SizedBox(height: 16.0),
             const Text(
               'Members',
               style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 8.0),
             Column(
               children: _memberIds.map((memberId) => FutureBuilder<DocumentSnapshot>(
                 future: FirebaseFirestore.instance.collection('users').doc(memberId).get(),
                 builder: (context, snapshot) {
                   if (snapshot.hasData && snapshot.data != null) {
                     final userData = snapshot.data!.data() as Map<String, dynamic>?;
                     final String memberName = userData?['displayName'] ?? memberId;
                     return ListTile(
                       leading: const CircleAvatar(child: Icon(Icons.person)),
                       title: Text(memberName),
                     );
                   } else if (snapshot.connectionState == ConnectionState.waiting) {
                     return const ListTile(
                       leading: CircleAvatar(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1))),
                       title: Text('Loading...'),
                     );
                   } else {
                     return ListTile(
                       leading: const CircleAvatar(child: Icon(Icons.person)),
                       title: Text(memberId),
                     );
                   }
                 },
               )).toList(),
             ),
             const SizedBox(height: 20.0),
             ElevatedButton(
               onPressed: () => _leaveGroup(context),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.redAccent,
               ),
               child: const Text(
                 'Leave Group',
                 style: TextStyle(color: Colors.white),
               ),
             ),
           ],
         ),
       ),
     );
   }
 }