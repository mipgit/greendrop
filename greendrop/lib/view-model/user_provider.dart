import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart' as app;
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/task_provider.dart';
import 'package:greendrop/view-model/tree_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class UserProvider with ChangeNotifier {
  app.User _user;
  List<Tree> _userTrees = []; // user's trees
  List<Task> _dailyUserTasks = []; // user's tasks
  List<TreeProvider> _treeProviders = []; // list of TreeProviders
  List<TaskProvider> _taskProviders = []; // list of TaskProviders
  Timer? _taskResetTimer;
  Duration _timeUntilNextReset = Duration.zero;
  bool _tasksNeedReset = false;

  app.User get user => _user;
  List<Tree> get userTrees => _userTrees;
  List<Task> get userTasks => _dailyUserTasks;
  List<TreeProvider> get treeProviders => _treeProviders;
  List<TaskProvider> get taskProviders => _taskProviders;
  Duration get timeUntilNextReset => _timeUntilNextReset;

  UserProvider(BuildContext context) : _user = _createEmptyUser() {
    _initializeUser(context);
  }

  static app.User _createEmptyUser() {
    return app.User(
      id: '',
      username: 'Guest',
      email: '',
      profilePicture: null,
      ownedTrees: [],
      dailyTasks: [],
      droplets: 100,
    );
  }

  void _initializeUser(BuildContext context) async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      _user = await _fetchUserDataFromFirestore(authUser);
    } else {
      _user = _createEmptyUser();
    }

    await _initializeUserTrees(context);
    await _initializeUserTasks(context);
    _startTaskResetTimer(context);
    notifyListeners();
  }

  @override
  void dispose() {
    _taskResetTimer?.cancel();
    super.dispose();
  }



  Future<app.User> _fetchUserDataFromFirestore(User? authUser) async {
    if (authUser == null) {
      return _createEmptyUser();
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authUser.uid)
            .get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final dailyTasksDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(authUser.uid)
              .collection('daily_tasks')
              .doc('current')
              .get();

      List<String> taskIds = [];
      if (dailyTasksDoc.exists && dailyTasksDoc.data() != null) {
        taskIds = List<String>.from(dailyTasksDoc.data()!['tasks'] ?? []);
      }

      return app.User(
        id: authUser.uid,
        username: userData['username'] ?? authUser.displayName ?? "Anonymous",
        email: userData['email'] ?? authUser.email ?? "",
        profilePicture: userData['profilePicture'],
        ownedTrees:
            (userData['ownedTrees'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [],
        dailyTasks: taskIds,
        droplets: userData['droplets'] ?? 0,
      );

    } else {
      final newUser = app.User(
        id: authUser.uid,
        username: authUser.displayName ?? "Anonymous",
        email: authUser.email ?? "",
        profilePicture: authUser.photoURL,
        ownedTrees: [],
        dailyTasks: [],
        droplets: 100,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .set({
            'username': newUser.username,
            'email': newUser.email,
            'profilePicture': newUser.profilePicture,
            'ownedTrees': newUser.ownedTrees,
            'dailyTasks': newUser.dailyTasks,
            'droplets': newUser.droplets,
          });

      return newUser;
    }
  }




  /*TREES*/

  Future<void> _initializeUserTrees(BuildContext context) async {
    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    await gardenProvider.dataLoaded;

    List<Tree> foundTrees = [];

    print('User ID: ${user.id}');
    print('User\'s owned tree IDs: ${user.ownedTrees}');
    print('Available trees in GardenProvider: ${gardenProvider.allAvailableTrees.map((t) => t.id).toList()}',);

    for (final ownedTreeData in user.ownedTrees) {
      final treeId = ownedTreeData['treeId'] as String?;
      final initialDropletsUsed = ownedTreeData['dropletsUsed'] as int? ?? 0;
      final initialCurLevel = ownedTreeData['curLevel'] as int? ?? 0;

      if (treeId != null) {
        try {
          final tree = gardenProvider.allAvailableTrees.firstWhere(
            (t) => t.id == treeId,
          );
          final updatedTree = Tree(
            id: tree.id,
            name: tree.name,
            description: tree.description,
            species: tree.species,
            price: tree.price,
            levels: tree.levels,
            dropletsUsed: initialDropletsUsed,
            curLevel: initialCurLevel,
          );
          foundTrees.add(updatedTree);
        } catch (e) {
          print('Warning: Tree with ID $treeId not found in catalog.');
        }
      }
    }

    _userTrees = foundTrees;
    _treeProviders = _userTrees.map((tree) => TreeProvider(tree)).toList();
    print('Found user trees: $_userTrees');
    print('Created tree providers: $_treeProviders');
    notifyListeners();
  }



  Future<void> buyTree(BuildContext context, String treeId) async {
    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    final treeToBuy = gardenProvider.allAvailableTrees.firstWhere(
      (tree) => tree.id == treeId,
      orElse:
          () => throw StateError('Tree with ID $treeId not found in catalog'),
    );

    print('Attempting to buy tree with ID: ${treeToBuy.id}');
    final alreadyOwned = user.ownedTrees.any(
      (ownedTree) => ownedTree['treeId'] == treeId,
    );

    if (_user.droplets >= treeToBuy.price && !alreadyOwned) {
      try {
        // take drops
        user.takeDroplets(treeToBuy.price);

        // update locally
        final newOwnedTree = {
          'treeId': treeToBuy.id,
          'dropletsUsed': 0,
          'curLevel': 0,
        };
        _user.ownedTrees.add(newOwnedTree);

        final boughtTree = gardenProvider.allAvailableTrees.firstWhere(
          (tree) => tree.id == treeId,
        );
        _userTrees.add(boughtTree);
        _treeProviders.add(TreeProvider(boughtTree));
        notifyListeners();

        // update firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({
              'droplets': user.droplets,
              'ownedTrees': FieldValue.arrayUnion([newOwnedTree]),
            });

      } catch (e) {
        // handling potential Firestore errors
        print('Error buying tree: $e');
        // revert local state changes if Firestore update fails ?
        _user.addDroplets(treeToBuy.price);
        _user.ownedTrees.removeWhere(
          (ownedTree) => ownedTree['treeId'] == treeId,
        );
        _userTrees.removeWhere((tree) => tree.id == treeId);
        _treeProviders.removeWhere((provider) => provider.tree.id == treeId);
        notifyListeners();
      }

    } else if (alreadyOwned) {
      print('You already own ${treeToBuy.name}.');
    } else {
      print('Not enough droplets to buy ${treeToBuy.name}.');
    }
  }


  Future<void> updateUserTreeInFirestore(Tree updatedTree) async {
    if (_user.id.isNotEmpty) {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user.id);
      final userData = (await userDocRef.get()).data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('ownedTrees')) {
        final List<dynamic> ownedTreesData = List<dynamic>.from(
          userData['ownedTrees'] ?? [],
        );
        final index = ownedTreesData.indexWhere(
          (item) => (item as Map?)?['treeId'] == updatedTree.id,
        );
        if (index != -1) {
          ownedTreesData[index] = {
            'treeId': updatedTree.id,
            'dropletsUsed': updatedTree.dropletsUsed,
            'curLevel': updatedTree.curLevel,
          };
          await userDocRef.update({'ownedTrees': ownedTreesData});
          print('Updated tree status in Firestore for ${updatedTree.id}');
        } else {
          print(
            'Warning: Tree ${updatedTree.id} not found in user\'s owned trees in Firestore.',
          );
        }
      }
    }
  }




  /*TASKS*/

  Future<void> _assignDailyTasks(BuildContext context) async {
    if (_user.id.isEmpty) return;

    final now = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(now);
    final dailyTasksDocRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

    final dailyTasksDoc = await dailyTasksDocRef.get();
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    await tasksProvider.dataLoaded;

    List<String> completedTaskIds = [];
    if (dailyTasksDoc.exists &&
        dailyTasksDoc.data() != null &&
        dailyTasksDoc.data()!.containsKey('completedTasks')) {
      completedTaskIds = List<String>.from(
        dailyTasksDoc.data()!['completedTasks'] ?? [],
      );
    }

    if (tasksProvider.allAvailableTasks.isNotEmpty &&
        (_tasksNeedReset ||
            !dailyTasksDoc.exists ||
            dailyTasksDoc.data()?['date'] != todayDate ||
            (dailyTasksDoc.data()?['tasks'] as List<dynamic>?)?.isEmpty == true)) {
      //we assign new tasks
      final random = Random();
      final availableTasks = List<Task>.from(tasksProvider.allAvailableTasks);
      final selectedTasks = <String>[];

      //for now we only want 4
      while (selectedTasks.length < 4 && availableTasks.isNotEmpty) {
        final randomIndex = random.nextInt(availableTasks.length);
        final taskId = availableTasks[randomIndex].id.toString();
        if (!selectedTasks.contains(taskId)) {
          selectedTasks.add(taskId);
        }
        availableTasks.removeAt(randomIndex);
      }

      await dailyTasksDocRef.set({'date': todayDate, 'tasks': selectedTasks});

      _dailyUserTasks =
          tasksProvider.allAvailableTasks
              .where((task) => selectedTasks.contains(task.id.toString()))
              .toList();

      // we check if any of them is completed on Firestore
      for (var task in _dailyUserTasks) {
        if (completedTaskIds.contains(task.id.toString())) {
          task.isCompleted = true;
        } else {
          task.isCompleted = false;
        }
      }

      _tasksNeedReset = false;
      notifyListeners();


    } else {
      final taskIds = List<String>.from(
        dailyTasksDoc.data()!['tasks'] as List<dynamic>,
      );
      _dailyUserTasks =
          tasksProvider.allAvailableTasks
              .where((task) => taskIds.contains(task.id.toString()))
              .toList();

      // we check if any of them is completed on Firestore
      for (var task in _dailyUserTasks) {
        if (completedTaskIds.contains(task.id.toString())) {
          task.isCompleted = true;
        } else {
          task.isCompleted = false;
        }
      }
      notifyListeners();
    }
  }


  Future<void> _initializeUserTasks(BuildContext context) async {
    await _assignDailyTasks(context);
    _taskProviders = _dailyUserTasks.map((task) => TaskProvider()).toList();
    notifyListeners();
  }


  Future<void> completeTask(Task task) async {
    if (!_dailyUserTasks.any((t) => t.id == task.id))
      return; // Ensure task belongs to user
    addDroplets(task.dropletReward);
    final index = _dailyUserTasks.indexWhere((t) => t.id == task.id);
    if (index != -1 && !_dailyUserTasks[index].isCompleted) {
      _dailyUserTasks[index].completeTask();
      notifyListeners();
    }

    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

    await dailyTasksDocRef.update({
      'completedTasks': FieldValue.arrayUnion([task.id,]), 
    });
  }

  Future<void> unCompleteTask(Task task) async {
    if (!_dailyUserTasks.any((t) => t.id == task.id))
      return; // Ensure task belongs to user
    takeDroplets(task.dropletReward);
    final index = _dailyUserTasks.indexWhere((t) => t.id == task.id);

    if (index != -1 && _dailyUserTasks[index].isCompleted) {
      _dailyUserTasks[index].unCompleteTask();
      notifyListeners();
    }

    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

    await dailyTasksDocRef.update({
      'completedTasks': FieldValue.arrayRemove([task.id,]), 
    });
  }




  Future<void> _clearCompletedTasks(BuildContext context) async {
    if (_user.id.isEmpty) return;

    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

    await dailyTasksDocRef.update({'completedTasks': FieldValue.delete()});

    for (var task in _dailyUserTasks) {
      if (task.isCompleted) {
        task.isCompleted = false;
      }
    }
  }

  void _startTaskResetTimer(BuildContext context) {
    _taskResetTimer?.cancel(); // Cancel any existing timer

    // reset on next midnight
    final now = DateTime.now();
    final nextReset = DateTime(now.year, now.month, now.day + 1);
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _timeUntilNextReset = nextReset.difference(now);

    // Start the timer
    _taskResetTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_timeUntilNextReset.inSeconds <= 0) {
        timer.cancel();
        _tasksNeedReset = true;
        _clearCompletedTasks(context);
        _assignDailyTasks(context);
        _startTaskResetTimer(context);
      } else {
        _timeUntilNextReset = nextReset.difference(DateTime.now());
        notifyListeners();
      }
    });

    print(
      'Task reset timer started. Tasks will reset in ${_timeUntilNextReset}',
    );
  }




  /*GENERAL*/

  void addDroplets(int amount) {
    _user.droplets +=
        amount; //this needs fixing but i dont want to change user class yet
    notifyListeners();
    _updateUserFirestore({'droplets': _user.droplets});
  }

  void takeDroplets(int amount) {
    user.droplets -= amount;
    notifyListeners();
    _updateUserFirestore({'droplets': _user.droplets});
  }

  Future<void> _updateUserFirestore(Map<String, dynamic> data) async {
    if (_user.id.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.id)
            .update(data);
      } catch (e) {
        print('Error updating user data in Firestore: $e');
        //  revert local state changes if the update fails ?
      }
    }
  }



}
