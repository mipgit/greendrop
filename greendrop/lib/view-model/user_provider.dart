import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:greendrop/model/task.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart' as app; // Alias your User model
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
    _initialize(context);
  }

  // --- MODIFIED ---
  static app.User _createEmptyUser() {
    return app.User(
      id: 'guest',
      username: 'Guest',
      email: '',
      profilePicture: null,
      bio: null, // <-- ADDED default bio
      ownedTrees: [],
      droplets: 300,
    );
  }

  //starting point for initialization
  Future<void> _initialize(BuildContext context) async {
    await _fetchInitialUser(context);
    // Only initialize related data if user is not guest (optional optimization)
    if (_user.id != 'guest') {
       await _initializeRelatedData(context);
       _startTaskResetTimer(context);
    } else {
      // Clear previous user data if switching to guest
       _userTrees = [];
       _dailyUserTasks = [];
       _treeProviders = [];
       _taskProviders = [];
       _taskResetTimer?.cancel();
    }
     _listenToAuthChanges(context); // Listen regardless of initial state
  }

  //we need to fetch user data
  Future<void> _fetchInitialUser(BuildContext context) async {
    // Use aliased FirebaseAuth
    final authUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (authUser != null && !authUser.isAnonymous) { // Check if not anonymous
      _user = await _fetchUserDataFromFirestore(authUser);
    } else {
      _user = _createEmptyUser();
    }
    notifyListeners(); // Notify after fetching/creating initial user
  }


  //we will handle the fetch (in Firestore) depending on the existence of the user or not
  // --- MODIFIED Parameter Type ---
  Future<app.User> _fetchUserDataFromFirestore(fb_auth.User authUser) async {
    // Removed redundant check for null/anonymous as it's handled in _fetchInitialUser

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .get();

    if (userDoc.exists) {
      return _createUserFromFirestore(
        authUser, // Pass the non-nullable authUser
        userDoc,
      ); //if the user exists we create the user from Firestore
    } else {
      return _createNewUserInFirestore(
        authUser, // Pass the non-nullable authUser
      ); //if the user does not exist we create a new one
    }
  }


  //we create the user from Firestore (only fetching data)
  // --- MODIFIED Parameter Type & Added Bio ---
  Future<app.User> _createUserFromFirestore(
      fb_auth.User authUser, // Use aliased, non-nullable type
      DocumentSnapshot<Map<String, dynamic>> userDoc) async {
    final userData = userDoc.data()!;

    // Fetching daily tasks doc - keep if needed, otherwise can remove
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(authUser.uid) // Use authUser passed in
    //     .collection('daily_tasks')
    //     .doc('current')
    //     .get();

    return app.User(
      id: authUser.uid,
      username: userData['username'] ?? authUser.displayName ?? "Anonymous",
      email: userData['email'] ?? authUser.email ?? "",
      profilePicture: userData['profilePicture'],
      bio: userData['bio'], // <-- ADDED fetching bio from Firestore data
      ownedTrees: (userData['ownedTrees'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      droplets: userData['droplets'] ?? 0,
    );
  }


  //we create a new user in Firestore (with default values)
  // --- MODIFIED Parameter Type & Added Bio ---
  Future<app.User> _createNewUserInFirestore(
      fb_auth.User authUser) async { // Use aliased, non-nullable type
    final newUser = app.User(
      id: authUser.uid, // Use authUser passed in
      username: authUser.displayName ?? "Anonymous",
      email: authUser.email ?? "",
      profilePicture: authUser.photoURL,
      bio: null, // <-- ADDED default bio for new user
      ownedTrees: [],
      droplets: 100,
    );
    // Save to Firestore
    await FirebaseFirestore.instance.collection('users').doc(authUser.uid).set({
      'username': newUser.username,
      'email': newUser.email,
      'profilePicture': newUser.profilePicture,
      'bio': newUser.bio, // <-- ADDED saving bio field
      'ownedTrees': newUser.ownedTrees,
      'droplets': newUser.droplets,
    });
    return newUser;
  }



  //we initialize the trees and the tasks of the user
  Future<void> _initializeRelatedData(BuildContext context) async {
     // Ensure we don't run this for guest user after login/logout cycle
    if (_user.id == 'guest') return;
    await _initializeUserTrees(context);
    await _initializeUserTasks(context);
    // Removed _listenToAuthChanges from here, it's called once in _initialize
  }


  //listener for authentication changes (when we sign out bla bla bla)
  void _listenToAuthChanges(BuildContext context) {
    fb_auth.FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
       print("Auth state changed. User: ${firebaseUser?.uid}");
      if (firebaseUser != null && !firebaseUser.isAnonymous) {
        _user = await _fetchUserDataFromFirestore(firebaseUser);
        // Re-initialize data for the logged-in user
        await _initializeRelatedData(context);
        _startTaskResetTimer(context); // Restart timer for logged-in user
      } else {
        _user = _createEmptyUser();
        // Clear data when logging out or becoming guest
         _userTrees = [];
         _dailyUserTasks = [];
         _treeProviders = [];
         _taskProviders = [];
         _taskResetTimer?.cancel(); // Stop timer for guest
      }

      notifyListeners(); // Notify after state change and data refresh/clear
    });
  }



  bool _isDisposed = false; // Track if the provider is disposed

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed
    _taskResetTimer?.cancel();
    // Consider cancelling auth subscription listener here if needed, though often managed by Provider lifecycle
    super.dispose();
  }


  /*TREES*/

  Future<void> _initializeUserTrees(BuildContext context) async {
    // Added check: Don't initialize if user is guest
    if (_user.id == 'guest') {
      _userTrees = [];
      _treeProviders = [];
      notifyListeners(); // Ensure UI updates if switching to guest
      return;
    }

    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    // Ensure garden data is loaded before proceeding
    await gardenProvider.dataLoaded;

    List<Tree> foundTrees = [];

    print('(InitTrees) User ID: ${user.id}');
    print('(InitTrees) User\'s owned tree data: ${user.ownedTrees}');
    print('(InitTrees) Available trees in GardenProvider: ${gardenProvider.allAvailableTrees.map((t) => t.id).toList()}',);

    // Check if ownedTrees is actually populated
     if (user.ownedTrees.isEmpty) {
       print('(InitTrees) User owns no trees.');
       _userTrees = [];
       _treeProviders = [];
       notifyListeners();
       return;
     }


    for (final ownedTreeData in user.ownedTrees) {
      // Defensive coding: ensure map structure is correct
      if (!ownedTreeData.containsKey('treeId')) {
          print('Warning: Invalid owned tree data format: $ownedTreeData');
          continue; // Skip this entry
      }
      final treeId = ownedTreeData['treeId'] as String?;
      final initialDropletsUsed = ownedTreeData['dropletsUsed'] as int? ?? 0;
      final initialCurLevel = ownedTreeData['curLevel'] as int? ?? 0;


      if (treeId != null) {
        try {
          // Use firstWhereOrNull for safer lookup
          final tree = gardenProvider.allAvailableTrees.firstWhere(
            (t) => t.id == treeId);
          // Create a new Tree instance with user-specific progress
          final updatedTree = Tree(
            id: tree.id,
            name: tree.name,
            description: tree.description,
            species: tree.species,
            price: tree.price,
            levels: tree.levels, // Keep original levels structure
            dropletsUsed: initialDropletsUsed, // User's progress
            curLevel: initialCurLevel,         // User's progress
          );
          foundTrees.add(updatedTree);
        } catch (e) { // Catch specific exception if needed (e.g., StateError)
          print('Warning: Tree with ID $treeId from user data not found in catalog.');
        }
      } else {
         print('Warning: Found owned tree data with null treeId.');
      }
    }

    _userTrees = foundTrees;
    // Create TreeProviders based on the user's specific tree instances
    _treeProviders = _userTrees.map((tree) => TreeProvider(tree)).toList();
    print('(InitTrees) Found user trees: ${_userTrees.map((t) => t.id).toList()}');
    print('(InitTrees) Created tree providers: ${_treeProviders.length}');
    notifyListeners();
  }


  Future<void> buyTree(BuildContext context, String treeId) async {
     // Prevent guest user from buying
    if (_user.id == 'guest') {
        print("Guest users cannot buy trees.");
        // Optionally show a message to the user
        return;
    }

    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    await gardenProvider.dataLoaded; // Ensure catalog is loaded

    final treeToBuy = gardenProvider.allAvailableTrees.firstWhere(
      (tree) => tree.id == treeId,
      orElse: () => throw StateError('Tree with ID $treeId not found in catalog'),
    );

    print('Attempting to buy tree with ID: ${treeToBuy.id}');
    final alreadyOwned = _user.ownedTrees.any( // Check internal _user state
      (ownedTree) => ownedTree['treeId'] == treeId,
    );

    // Check droplets and ownership
    if (_user.droplets >= treeToBuy.price && !alreadyOwned) {
      final price = treeToBuy.price; // Store price before modification

      // Use the takeDroplets method which handles Firestore update
      takeDroplets(price); // This will notify listeners and update Firestore

      // update local user model immediately
      final newOwnedTreeData = {
        'treeId': treeToBuy.id,
        'dropletsUsed': 0,
        'curLevel': 0,
      };
      _user.ownedTrees.add(newOwnedTreeData);

      // Add the *base* tree from the catalog to the local list and create provider
      // IMPORTANT: We need a new instance reflecting the purchase state (0 droplets, level 0)
      final boughtTreeInstance = Tree(
        id: treeToBuy.id,
        name: treeToBuy.name,
        description: treeToBuy.description,
        species: treeToBuy.species,
        price: treeToBuy.price,
        levels: treeToBuy.levels,
        dropletsUsed: 0, // Start at 0
        curLevel: 0,     // Start at 0
      );
      _userTrees.add(boughtTreeInstance);
      _treeProviders.add(TreeProvider(boughtTreeInstance));

      // Explicitly update Firestore with the new ownedTrees array for the user
      // Note: takeDroplets already updated the droplet count
      try {
        await _updateUserFirestore({
          'ownedTrees': FieldValue.arrayUnion([newOwnedTreeData]),
          });
        print("Tree purchased successfully and Firestore updated.");
      } catch (e) {
         print('Error updating ownedTrees in Firestore after purchase: $e');
         // Revert local state if Firestore update fails
         addDroplets(price); // Give back droplets (will trigger another Firestore update)
         _user.ownedTrees.removeWhere((ot) => ot['treeId'] == treeId);
         _userTrees.removeWhere((tree) => tree.id == treeId);
         _treeProviders.removeWhere((provider) => provider.tree.id == treeId);
         notifyListeners(); // Notify UI of reversion
      }


    } else if (alreadyOwned) {
      print('You already own ${treeToBuy.name}.');
      // Optionally show user message
    } else {
      print('Not enough droplets to buy ${treeToBuy.name}.');
      // Optionally show user message
    }
     // No need for notifyListeners() here if takeDroplets and potential revert handle it.
  }


  Future<void> updateUserTreeInFirestore(Tree updatedTree) async {
    // Prevent updates for guest user
    if (_user.id.isEmpty || _user.id == 'guest') return;

    // Update the local lists first for immediate UI feedback
    final treeIndex = _userTrees.indexWhere((t) => t.id == updatedTree.id);
    if (treeIndex != -1) {
      _userTrees[treeIndex] = updatedTree;
    }
    final providerIndex = _treeProviders.indexWhere((p) => p.tree.id == updatedTree.id);
     if (providerIndex != -1) {
       // Assuming TreeProvider holds a reference, update might not be needed
       // If TreeProvider makes a copy, you'd update it: _treeProviders[providerIndex] = TreeProvider(updatedTree);
       // Or more likely, the TreeProvider updates its internal tree state and notifies.
     }

    // Update the corresponding entry in the user's ownedTrees list (local model)
     final ownedTreeIndex = _user.ownedTrees.indexWhere((ot) => ot['treeId'] == updatedTree.id);
     if (ownedTreeIndex != -1) {
       _user.ownedTrees[ownedTreeIndex] = {
         'treeId': updatedTree.id,
         'dropletsUsed': updatedTree.dropletsUsed,
         'curLevel': updatedTree.curLevel,
       };
     }

     notifyListeners(); // Update UI with local changes

    // Now update Firestore
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(_user.id);
      // Fetch the current data to modify the array correctly
      final userDoc = await userDocRef.get();
       final userData = userDoc.data();

      if (userData != null && userData.containsKey('ownedTrees')) {
        // Get the list, ensure it's modifiable
        final List<dynamic> ownedTreesData = List<dynamic>.from(userData['ownedTrees'] ?? []);
        final indexToUpdate = ownedTreesData.indexWhere((item) => (item as Map?)?['treeId'] == updatedTree.id);

        if (indexToUpdate != -1) {
          // Update the specific map in the list
          ownedTreesData[indexToUpdate] = {
            'treeId': updatedTree.id,
            'dropletsUsed': updatedTree.dropletsUsed,
            'curLevel': updatedTree.curLevel,
          };
          // Update the entire array field in Firestore
          await userDocRef.update({'ownedTrees': ownedTreesData});
          print('Updated tree status in Firestore for ${updatedTree.id}');
        } else {
          print('Warning: Tree ${updatedTree.id} not found in user\'s owned trees in Firestore during update.');
        }
      } else {
         print('Warning: ownedTrees field not found or user data is null in Firestore during tree update.');
      }
    } catch (e) {
       print('Error updating tree ${updatedTree.id} in Firestore: $e');
       // Consider reverting local changes or showing an error message
    }
  }


  /*TASKS*/
  // (Task methods remain largely unchanged from your original code, unless bio affects them)
  // ... [Your existing _initializeUserTasks, _assignDailyTasks, addPersonalizedTask, etc.] ...
  // ... [completeTask, unCompleteTask, reorderTasks, removePersonalizedTask] ...
  // ... [_clearTasks, _startTaskResetTimer] ...


  Future<void> _initializeUserTasks(BuildContext context) async {
     if (_user.id == 'guest') {
       _dailyUserTasks = [];
       _taskProviders = [];
       notifyListeners();
       return;
     }
    await _assignDailyTasks(context);
    // Ensure TaskProvider creation matches the logic
    _taskProviders = _dailyUserTasks.map((task) => TaskProvider(/* Pass task if needed */)).toList();
    notifyListeners();
  }



  Future<void> _assignDailyTasks(BuildContext context) async {
    if (_user.id.isEmpty || _user.id == 'guest') return; // Added guest check

    final now = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(now);
    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

    final dailyTasksDoc = await dailyTasksDocRef.get();
    // Ensure TaskProvider is correctly referenced (assuming it has all tasks)
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    await tasksProvider.dataLoaded; // Make sure base tasks are loaded

    List<String> completedTaskIds = [];
    List<Map<String, dynamic>> personalizedTasksMap = [];
    List<String> currentTaskIds = []; // Store the task IDs assigned for the day

    if (dailyTasksDoc.exists && dailyTasksDoc.data() != null) {
       final data = dailyTasksDoc.data()!;
       if (data.containsKey('tasks')) {
          currentTaskIds = List<String>.from(data['tasks'] ?? []);
       }
       if (data.containsKey('personalized_tasks_map')) {
         personalizedTasksMap = List<Map<String, dynamic>>.from(data['personalized_tasks_map'] ?? []);
       }
       if (data.containsKey('completedTasks')) {
         completedTaskIds = List<String>.from(data['completedTasks'] ?? []);
       }
    }


    // Check if the tasks need to be reset
    bool needsReset = _tasksNeedReset ||
            !dailyTasksDoc.exists ||
            dailyTasksDoc.data()?['date'] != todayDate ||
             currentTaskIds.isEmpty; // Reset if no tasks assigned for today

    if (tasksProvider.allAvailableTasks.isNotEmpty && needsReset) {
       print("Assigning new daily tasks for $todayDate");
       await _clearTasks(context); // Clear completed/personalized from previous day FIRST

       final random = Random();
       // Ensure we don't select more tasks than available
       final numTasksToSelect = min(4, tasksProvider.allAvailableTasks.length);
       final availableTasks = List<Task>.from(tasksProvider.allAvailableTasks);
       final selectedTaskIds = <String>[];

        while (selectedTaskIds.length < numTasksToSelect && availableTasks.isNotEmpty) {
            final randomIndex = random.nextInt(availableTasks.length);
            final taskId = availableTasks[randomIndex].id.toString();
            // Check if already selected (shouldn't happen with removeAt, but safe)
            if (!selectedTaskIds.contains(taskId)) {
                selectedTaskIds.add(taskId);
            }
            availableTasks.removeAt(randomIndex); // Remove to avoid duplicates
        }

        // Update Firestore with new tasks for the day
        await dailyTasksDocRef.set({
          'date': todayDate,
          'tasks': selectedTaskIds,
          'personalized_tasks_map': [], // Start fresh personalized tasks
          'completedTasks': [],      // Start fresh completed tasks
        });

        // Update local state
        currentTaskIds = selectedTaskIds; // These are the tasks for today
        _dailyUserTasks = tasksProvider.allAvailableTasks
            .where((task) => currentTaskIds.contains(task.id.toString()))
            .toList();
        personalizedTasksMap = []; // Clear local personalized map
        completedTaskIds = [];     // Clear local completed list

        _tasksNeedReset = false; // Reset the flag

    } else if (dailyTasksDoc.exists) {
         print("Loading existing tasks for $todayDate");
        // Load tasks based on IDs stored in Firestore for the current day
        _dailyUserTasks = tasksProvider.allAvailableTasks
             .where((task) => currentTaskIds.contains(task.id.toString()))
             .toList();
    } else {
       print("No tasks document found and not resetting. Task list might be empty.");
       _dailyUserTasks = []; // Ensure list is empty if no doc and no reset
    }


    // --- Process Personalized Tasks AFTER standard tasks are set ---

    List<Task> tasksToAddFromPersonalized = [];
    for (var taskMap in personalizedTasksMap) {
         final String? taskId = taskMap['id'] as String?;
         final String? description = taskMap['description'] as String?;
         final int dropletReward = taskMap['dropletReward'] as int? ?? 1; // Default reward

        if(taskId == null || description == null) {
          print("Warning: Invalid personalized task data found: $taskMap");
          continue;
        }

         // Check if this personalized task ID already exists in the standard daily tasks
         final existingTaskIndex = _dailyUserTasks.indexWhere((t) => t.id == taskId);

         if (existingTaskIndex != -1) {
             // If it exists (e.g., was a standard task), just mark it as personalized
             _dailyUserTasks[existingTaskIndex].isPersonalized = true;
         } else {
             // If it doesn't exist, create a new Task object for it
             final newPersonalizedTask = Task(
                 id: taskId,
                 description: description,
                 dropletReward: dropletReward,
                 creationDate: DateTime.now(), // Or load from Firestore if stored
                 isPersonalized: true,
             );
             // Add to a temporary list to append later, avoids concurrent modification issues
             tasksToAddFromPersonalized.add(newPersonalizedTask);
         }
    }
    // Add all newly created personalized tasks to the main list
    _dailyUserTasks.addAll(tasksToAddFromPersonalized);


    // --- Final pass: Mark completed status ---
    for (var task in _dailyUserTasks) {
         task.isCompleted = completedTaskIds.contains(task.id.toString());
         // Ensure personalization status from above steps is maintained
         // task.isPersonalized = task.isPersonalized || personalizedTasksMap.any((map) => map['id'] == task.id);
    }

    notifyListeners();
  }


  void addPersonalizedTask(Task task) {
     if (_user.id == 'guest') {
       print("Guest users cannot add personalized tasks.");
       return;
     }

    final personalizedTasksCount = _dailyUserTasks.where((t) => t.isPersonalized).length;
    if (personalizedTasksCount >= 3) {
      print('You can only create up to 3 personalized tasks.');
      return;
    }

    // Ensure task is marked and added locally
    task.isPersonalized = true;
    // Avoid adding duplicates if somehow possible
    if (!_dailyUserTasks.any((t) => t.id == task.id)) {
       _dailyUserTasks.add(task);
       notifyListeners();
    }


    // Update Firestore
    final Map<String, dynamic> personalizedTaskData = {
      'id': task.id,
      'description': task.description,
      'dropletReward': task.dropletReward,
      // Add other relevant fields if needed, like creationDate
    };

    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current')
        .update({
          // Use arrayUnion to add the map to the list
          'personalized_tasks_map': FieldValue.arrayUnion([personalizedTaskData]),
        }).catchError((error) {
           print("Error adding personalized task to Firestore: $error");
           // Revert local change if Firestore fails
           _dailyUserTasks.removeWhere((t) => t.id == task.id);
           notifyListeners();
        });
  }


  Future<void> completeTask(Task task) async {
     if (_user.id == 'guest') {
       print("Guest user: Task completion not saved to Firestore.");
       // Optionally update locally for guest session
        final index = _dailyUserTasks.indexWhere((t) => t.id == task.id);
        if (index != -1 && !_dailyUserTasks[index].isCompleted) {
           addDroplets(task.dropletReward); // Still give droplets locally?
           _dailyUserTasks[index].completeTask();
           notifyListeners();
        }
       return;
     }

    // Ensure task exists locally before proceeding
    final index = _dailyUserTasks.indexWhere((t) => t.id == task.id);
    if (index == -1 || _dailyUserTasks[index].isCompleted) return; // Not found or already completed

    // Update locally first
    addDroplets(task.dropletReward); // This handles Firestore update for droplets
    _dailyUserTasks[index].completeTask();
    notifyListeners(); // Update UI


    // Update Firestore completedTasks list
    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

     try {
       await dailyTasksDocRef.update({'completedTasks': FieldValue.arrayUnion([task.id])});
       print("Task ${task.id} marked completed in Firestore.");
     } catch (e) {
        print("Error marking task ${task.id} complete in Firestore: $e");
        // Revert local changes
        takeDroplets(task.dropletReward); // Take back droplets
        _dailyUserTasks[index].unCompleteTask();
        notifyListeners();
     }
  }


  Future<void> unCompleteTask(Task task) async {
      if (_user.id == 'guest') {
       print("Guest user: Task un-completion not saved to Firestore.");
        final index = _dailyUserTasks.indexWhere((t) => t.id == task.id);
        if (index != -1 && _dailyUserTasks[index].isCompleted) {
           takeDroplets(task.dropletReward); // Take back droplets locally?
           _dailyUserTasks[index].unCompleteTask();
           notifyListeners();
        }
       return;
     }

    final index = _dailyUserTasks.indexWhere((t) => t.id == task.id);
    // Ensure task exists locally and is actually completed
    if (index == -1 || !_dailyUserTasks[index].isCompleted) return;

    // Update locally first
    takeDroplets(task.dropletReward); // Handles Firestore update for droplets
    _dailyUserTasks[index].unCompleteTask();
    notifyListeners(); // Update UI

    // Update Firestore completedTasks list
    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

      try {
         await dailyTasksDocRef.update({'completedTasks': FieldValue.arrayRemove([task.id])});
         print("Task ${task.id} marked un-completed in Firestore.");
      } catch (e) {
         print("Error marking task ${task.id} un-complete in Firestore: $e");
         // Revert local changes
         addDroplets(task.dropletReward); // Give back droplets
         _dailyUserTasks[index].completeTask();
         notifyListeners();
      }
  }


  void reorderTasks(int oldIndex, int newIndex) {
     // Prevent reordering for guest
     if (_user.id == 'guest') return;

    // Adjust index for inserting after removal
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final task = _dailyUserTasks.removeAt(oldIndex);
    _dailyUserTasks.insert(newIndex, task);
    notifyListeners();

    // Update Firestore with the new order of *all* task IDs (standard + personalized)
     final allTaskIds = _dailyUserTasks.map((task) => task.id).toList();
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current')
        .update({'tasks': allTaskIds}) // Update the main 'tasks' list order
        .catchError((error) {
           print("Error updating task order in Firestore: $error");
           // Consider reverting local reorder
        });
  }


  void removePersonalizedTask(Task task) {
     // Ensure it's actually a personalized task we intend to remove
    if (!task.isPersonalized) return;
    if (_user.id == 'guest') {
       print("Guest user: Cannot remove personalized task from Firestore.");
        _dailyUserTasks.removeWhere((t) => t.id == task.id);
        notifyListeners();
       return;
    }


    // Remove locally
    _dailyUserTasks.removeWhere((t) => t.id == task.id);
    notifyListeners();

    // --- Update Firestore ---
    // We need to remove the task map from 'personalized_tasks_map'
    // AND potentially remove its ID from 'tasks' and 'completedTasks' if it was added there.

    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

     // Create the map representation of the task to remove from the array
     final Map<String, dynamic> personalizedTaskDataToRemove = {
         'id': task.id,
         'description': task.description,
         'dropletReward': task.dropletReward,
         // Include any other fields that were stored in the map
     };


    dailyTasksDocRef.update({
      // Remove the map from the personalized list
      'personalized_tasks_map': FieldValue.arrayRemove([personalizedTaskDataToRemove]),
      // Also remove the ID from the main task list if it exists there
      'tasks': FieldValue.arrayRemove([task.id]),
      // Also remove the ID from completed tasks if it exists there
      'completedTasks': FieldValue.arrayRemove([task.id]),
    }).catchError((error) {
       print("Error removing personalized task ${task.id} from Firestore: $error");
       // Re-add locally if Firestore update failed
       _dailyUserTasks.add(task); // simplistic re-add, might mess order
       notifyListeners();
    });
  }


  // Clears completed and personalized tasks, typically called at day reset
  Future<void> _clearTasks(BuildContext context) async {
    // No need to clear for guest, but check added for safety
    if (_user.id.isEmpty || _user.id == 'guest') return;

    print("Clearing completed and personalized tasks for user ${_user.id}");
    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

     try {
      // Check if doc exists before trying to update non-existent fields
      final doc = await dailyTasksDocRef.get();
      if (doc.exists) {
        await dailyTasksDocRef.update({
           // Use delete() if you want the fields gone, or set to [] if you want empty lists
           'completedTasks': [], // Reset to empty list
           'personalized_tasks_map': [], // Reset to empty list
         });
         print("Firestore tasks cleared.");
      } else {
         print("Daily tasks document doesn't exist, nothing to clear.");
      }
     } catch (e) {
        print("Error clearing tasks in Firestore: $e");
     }


    // Clear locally as well
    for (var task in _dailyUserTasks) {
      task.isCompleted = false;
      // Decide if personalized tasks should be removed entirely or just reset
      // Current logic removes them via personalized_tasks_map: [] above.
      // If you want to keep them but reset status, adjust Firestore update and here.
    }
     _dailyUserTasks.removeWhere((task) => task.isPersonalized); // Remove local personalized tasks
    notifyListeners();
  }


  void _startTaskResetTimer(BuildContext context) {
    // Prevent timer for guest user
     if (_user.id == 'guest') {
       _taskResetTimer?.cancel(); // Ensure any previous timer is cancelled
       _timeUntilNextReset = Duration.zero;
       print("Task reset timer stopped for guest user.");
       notifyListeners(); // Update UI if displaying timer
       return;
     }

    _taskResetTimer?.cancel(); // cancel any existing timer

    final now = DateTime.now();
    final nextReset = DateTime(now.year, now.month, now.day + 1); // Midnight tonight
    _timeUntilNextReset = nextReset.difference(now);

    print('Task reset timer starting. Next reset at: $nextReset (in $_timeUntilNextReset)');

    _taskResetTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      // +++ ADDED: Check if disposed at the very beginning +++
      if (_isDisposed) {
        print("Timer fired but provider is disposed. Cancelling timer.");
        timer.cancel();
        return;
      }
      // +++ END ADDED +++

      final currentTime = DateTime.now();
      // *** MODIFIED: Safer recalculation of nextReset ***
      final nextReset = DateTime(currentTime.year, currentTime.month, currentTime.day + 1);
      final newTimeUntilReset = nextReset.difference(currentTime);

      // *** MODIFIED: Added check for actual duration change ***
      if (_timeUntilNextReset != newTimeUntilReset) {
        _timeUntilNextReset = newTimeUntilReset; // Update the provider's state

        if (_timeUntilNextReset.isNegative || _timeUntilNextReset.inSeconds <= 0) {
           // ... (Reset logic - also added _isDisposed checks inside .then()) ...
           print("Reset time reached!");
           timer.cancel(); // Stop this timer first
           _tasksNeedReset = true; // Set flag

           if (!_isDisposed) { // Check disposed before async operation
              _assignDailyTasks(context).then((_) {
                  if (!_isDisposed) { // Check disposed again before restart
                    _startTaskResetTimer(context);
                  } else {
                     print("Provider disposed before timer could be restarted.");
                  }
              }).catchError((e) {
                  print("Error assigning daily tasks after reset: $e");
                  if (!_isDisposed) { /* maybe restart timer */ }
              });
            } else {
               print("Provider disposed before task assignment could start.");
            }

        } else {
          // --- *** THIS IS THE KEY CHANGE *** ---
          // --- REMOVED: The 'if (currentTime.second == 0 ...)' condition ---
          // --- NOW: Always notify listeners when time changes and it's not reset time ---
          notifyListeners();
          // --- *** END OF KEY CHANGE *** ---
        }
      } else if (_timeUntilNextReset.isNegative || _timeUntilNextReset.inSeconds <= 0 && timer.isActive) {
         // +++ ADDED: Edge case handling if duration didn't change but reset time met +++
         print("Reset time reached (duration check skipped).");
         timer.cancel();
          _tasksNeedReset = true;
          if (!_isDisposed) { // Check disposed
            _assignDailyTasks(context).then((_) {
              if (!_isDisposed) _startTaskResetTimer(context); // Check disposed
            }).catchError((e) {
              print("Error assigning daily tasks: $e");
              return null;
            });
          }
         // +++ END ADDED +++
      }

    }); 
  }


  /*GENERAL*/

  // --- MODIFIED: Added guest check ---
  void addDroplets(int amount) {
    if (amount <= 0) return; // Don't add zero or negative
    if (_user.id == 'guest') {
       _user.addDroplets(amount); // Update locally for guest
       print("Guest droplets updated locally to ${_user.droplets}");
       notifyListeners();
       return;
    }
    // Update local state first
    _user.addDroplets(amount);
    notifyListeners();
    // Update Firestore
    _updateUserFirestore({'droplets': _user.droplets});
  }

  // --- MODIFIED: Added guest & sufficient funds check ---
  void takeDroplets(int amount) {
    if (amount <= 0) return; // Don't take zero or negative
    if (_user.id == 'guest') {
      // Decide guest behavior: allow going negative or cap at 0?
      if (_user.droplets >= amount) {
          _user.takeDroplets(amount);
          print("Guest droplets updated locally to ${_user.droplets}");
      } else {
         print("Guest has insufficient droplets.");
         _user.droplets = 0; // Or set to 0 if preferred
      }
      notifyListeners();
      return;
    }

    // Check if user has enough droplets
    if (_user.droplets >= amount) {
       // Update local state first
      _user.takeDroplets(amount);
      notifyListeners();
      // Update Firestore
      _updateUserFirestore({'droplets': _user.droplets});
    } else {
      print("Insufficient droplets. User has ${_user.droplets}, tried to take $amount");
      // Optionally throw an error or show a message
    }
  }

  // --- NEW METHOD ---
  Future<void> updateUserBio(String newBio) async {
    // Prevent guest users from saving bio to Firestore
    if (_user.id == 'guest') {
        _user.bio = newBio; // Update locally for guest
        notifyListeners();
        print("Guest bio updated locally.");
        return;
    }

     // Limit bio length server-side as well (optional but good practice)
     final trimmedBio = newBio.length > 150 ? newBio.substring(0, 150) : newBio; // Example limit

    // Update local user object immediately for responsiveness
    if (_user.bio != trimmedBio) {
      _user.bio = trimmedBio;
      notifyListeners(); // Notify listeners of the local change
       // Update Firestore
      await _updateUserFirestore({'bio': trimmedBio});
      print("User bio updated in Firestore.");
    } else {
       print("Bio unchanged, skipping update.");
    }

  }
  // --- END OF NEW METHOD ---


  // --- MODIFIED: Added guest check ---
  Future<void> _updateUserFirestore(Map<String, dynamic> data) async {
    // Double-check: Only update if user ID is valid and not guest
    if (_user.id.isNotEmpty && _user.id != 'guest') {
      try {
        print("Updating Firestore for user ${_user.id} with data: $data");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.id)
            .update(data);
        print("Firestore update successful.");
      } catch (e) {
        print('Error updating user data in Firestore for user ${_user.id}: $e');
        // Consider reverting local state changes or notifying user of failure
      }
    } else {
       print("Skipping Firestore update for guest user or empty ID.");
    }
  }

   // Helper to check if provider is still mounted (useful in async callbacks)
   // Removed unnecessary mounted getter

} // End of UserProvider class
