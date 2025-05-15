import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:greendrop/model/task.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

class GroupProvider with ChangeNotifier {
  final String groupId;
  Task? _dailyGroupTask;
  bool _taskCompleted = false;
  Timer? _taskResetTimer;

  Task? get dailyGroupTask => _dailyGroupTask;
  bool get taskCompleted => _taskCompleted;

  List<String> _completedBy = [];
  List<String> get completedBy => _completedBy;

  bool hasUserCompleted(String userId) => _completedBy.contains(userId);

  GroupProvider(this.groupId);




  Future<void> assignDailyTask(BuildContext context) async {
    final now = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(now);
    final dailyTaskDocRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('daily_task')
        .doc('current');

    final dailyTaskDoc = await dailyTaskDocRef.get();
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    await tasksProvider.dataLoaded;

    bool doReset = !dailyTaskDoc.exists ||
        dailyTaskDoc.data()?['date'] != todayDate ||
        dailyTaskDoc.data()?['taskId'] == null;

    if (tasksProvider.allAvailableTasks.isNotEmpty && doReset) {
      // Pick a random task
      final random = Random();
      final availableTasks = List<Task>.from(tasksProvider.allAvailableTasks);
      final randomTask = availableTasks[random.nextInt(availableTasks.length)];

      await dailyTaskDocRef.set({
        'date': todayDate,
        'taskId': randomTask.id,
        'completedBy': <String>[],
      });

      _dailyGroupTask = randomTask;
      _taskCompleted = false;
    } else if (dailyTaskDoc.exists && dailyTaskDoc.data() != null) {
      final taskId = dailyTaskDoc.data()!['taskId'];
      final completedList = dailyTaskDoc.data()!['completedBy'] as List<dynamic>? ?? [];
      _completedBy = List<String>.from(completedList);
       _dailyGroupTask = tasksProvider.allAvailableTasks.firstWhere(
        (task) => task.id == taskId,
      );
    }

    notifyListeners();
  }

  Future<void> completeGroupTask(BuildContext context, String userId) async {
  if (_dailyGroupTask == null) return;

  if (!_completedBy.contains(userId)) {
    final int reward = (_dailyGroupTask?.dropletReward ?? 1) * 2;

    // Update user's droplets via UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.addDroplets(reward);

    // Update Firestore group daily task
    final dailyTaskDocRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('daily_task')
        .doc('current');
    await dailyTaskDocRef.update({
      'completedBy': FieldValue.arrayUnion([userId])
    });

    // Update local state
    _completedBy.add(userId);
    notifyListeners();
  }
}

  

  Future<void> unCompleteGroupTask(BuildContext context, String userId) async {
  if (_dailyGroupTask == null) return;
  final dailyTaskDocRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('daily_task')
      .doc('current');

  // Remove user from completedBy in Firestore
  await dailyTaskDocRef.update({
    'completedBy': FieldValue.arrayRemove([userId])
  });

  // Remove double reward via UserProvider
  final int reward = (_dailyGroupTask?.dropletReward ?? 1) * 2;
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  userProvider.addDroplets(-reward);

  // Update local state
  _completedBy.remove(userId);
  notifyListeners();
}




  void startTaskResetTimer(BuildContext context) {
    _taskResetTimer?.cancel();
    final now = DateTime.now();
    final nextReset = DateTime(now.year, now.month, now.day + 1);
    _taskResetTimer = Timer(nextReset.difference(now), () async {
      await assignDailyTask(context);
      startTaskResetTimer(context);
    });
  }

  @override
  void dispose() {
    _taskResetTimer?.cancel();
    super.dispose();
  }
}