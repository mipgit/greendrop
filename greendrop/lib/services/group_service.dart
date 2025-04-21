import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/model/group.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:provider/provider.dart';

class GroupService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  String? _getCurrentUserId(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(context, listen: false);
    return authService.email;
  }

  Future<void> fetchUserGroups(BuildContext context) async {
    final userId = _getCurrentUserId(context);
    if (userId == null) {
      print('User not authenticated, cannot fetch groups.');
      _groups = [];
      notifyListeners();
      return;
    }
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('groups')
          .where('memberIds', arrayContains: userId)
          .get();
      _groups = snapshot.docs.map((doc) => _groupFromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching user groups: $e');
      _groups = [];
      notifyListeners();
      throw Exception('Failed to fetch user groups');
    }
  }

  Future<Group?> createGroup(BuildContext context, String groupName) async {
    final creatorId = _getCurrentUserId(context);
    if (creatorId == null) {
      print('User not authenticated, cannot create group.');
      return null;
    }
    try {
      final newGroupRef = _firestore.collection('groups').doc();
      final creationDate = DateTime.now();
      final newGroup = Group(
        id: newGroupRef.id,
        name: groupName,
        creatorId: creatorId,
        creationDate: creationDate,
        memberIds: [creatorId],
      );
      await newGroupRef.set({
        'name': newGroup.name,
        'creatorId': newGroup.creatorId,
        'creationDate': Timestamp.fromDate(newGroup.creationDate),
        'memberIds': newGroup.memberIds,
      });
      fetchUserGroups(context);
      return newGroup;
    } catch (e) {
      print('Error creating group: $e');
      return null;
    }
  }

  Future<bool> joinGroup(BuildContext context, String groupId) async {
    final userId = _getCurrentUserId(context);
    if (userId == null) {
      print('User not authenticated, cannot join group.');
      return false;
    }
    try {
      final groupRef = _firestore.collection('groups').doc(groupId);
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await groupRef.get();
      if (snapshot.exists) {
        await groupRef.update({
          'memberIds': FieldValue.arrayUnion([userId]),
        });
        fetchUserGroups(context);
        return true;
      } else {
        print('Group with ID: $groupId does not exist.');
        return false;
      }
    } catch (e) {
      print('Error joining group: $e');
      return false;
    }
  }

  Group _groupFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creationDate: (data['creationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberIds: (data['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}