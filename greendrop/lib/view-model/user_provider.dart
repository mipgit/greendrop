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
  bool _isLoading = true;
  List<Tree> _userTrees = []; // user's trees
  List<Task> _dailyUserTasks = []; // user's tasks
  List<TreeProvider> _treeProviders = []; // list of TreeProviders
  List<TaskProvider> _taskProviders = []; // list of TaskProviders
  Timer? _taskResetTimer;
  Duration _timeUntilNextReset = Duration.zero;
  bool _tasksNeedReset = false;

  app.User get user => _user;
  bool get isLoading => _isLoading;
  List<Tree> get userTrees => _userTrees;
  List<Task> get userTasks => _dailyUserTasks;
  List<TreeProvider> get treeProviders => _treeProviders;
  List<TaskProvider> get taskProviders => _taskProviders;
  Duration get timeUntilNextReset => _timeUntilNextReset;

  UserProvider(BuildContext context) : _user = _createEmptyUser() {
    _initialize(context);
  }


  static app.User _createEmptyUser() {
    return app.User(
      id: 'guest',
      username: 'Guest',
      email: '',
      profilePicture: null,
      bio: null, 
      ownedTrees: [],
      droplets: 300,
    );
  }

  //starting point for initialization
  Future<void> _initialize(BuildContext context) async {
    try {
      await _fetchInitialUser(context);
      if (_user.id != 'guest') {
         await _initializeRelatedData(context);
      }
      _startTaskResetTimer(context);
      _listenToAuthChanges(context);
    } catch (e) {
      print("Error during initialization: $e");
      _user = _createEmptyUser();
    } finally {
      _isLoading = false; 
      notifyListeners(); 
    }
  }


  //we need to fetch user data
  Future<void> _fetchInitialUser(BuildContext context) async {
    final authUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) { 
      _user = await _fetchUserDataFromFirestore(authUser);
    } else {
      _user = _createEmptyUser();
    }
    //notifyListeners(); 
  }


  //we will handle the fetch (in Firestore) depending on the existence of the user or not
  Future<app.User> _fetchUserDataFromFirestore(fb_auth.User authUser) async {

    if (authUser.isAnonymous) {
      return _createEmptyUser(); 
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .get();

    if (userDoc.exists) {
      return _createUserFromFirestore(
        authUser, 
        userDoc,
      ); //if the user exists we create the user from Firestore
    } else {
      return _createNewUserInFirestore(
        authUser,
      ); //if the user does not exist we create a new one
    }
  }


  //we create the user from Firestore (only fetching data)
  Future<app.User> _createUserFromFirestore(fb_auth.User authUser, DocumentSnapshot<Map<String, dynamic>> userDoc) async {
    final userData = userDoc.data()!;

    String? originalPhotoURL = authUser.photoURL;
    String? highResPhotoURL = originalPhotoURL; 

    if (originalPhotoURL != null) {
      final sizeParamRegex = RegExp(r'=s\d+(-c)?$');
      if (sizeParamRegex.hasMatch(originalPhotoURL)) {
        highResPhotoURL = originalPhotoURL.replaceFirst(sizeParamRegex, '');
      }
    }

    return app.User(
      id: authUser.uid,
      username: userData['username'] ?? authUser.displayName ?? "Anonymous",
      email: userData['email'] ?? authUser.email ?? "",
      profilePicture: highResPhotoURL,
      bio: userData['bio'], // <-- ADDED fetching bio from Firestore data
      ownedTrees: (userData['ownedTrees'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      droplets: userData['droplets'] ?? 0,
    );
  }


  //we create a new user in Firestore (with default values)
  Future<app.User> _createNewUserInFirestore(fb_auth.User authUser) async { 
    
    String? originalPhotoURL = authUser.photoURL;
    String? highResPhotoURL = originalPhotoURL; 

    if (originalPhotoURL != null) {
      final sizeParamRegex = RegExp(r'=s\d+(-c)?$');
      if (sizeParamRegex.hasMatch(originalPhotoURL)) {
        highResPhotoURL = originalPhotoURL.replaceFirst(sizeParamRegex, '');
      }
    }
    
    final newUser = app.User(
      id: authUser.uid, 
      username: authUser.displayName ?? "Anonymous",
      email: authUser.email ?? "",
      profilePicture: highResPhotoURL,
      bio: null, 
      ownedTrees: [],
      droplets: 100,
    );

    await FirebaseFirestore.instance.collection('users').doc(authUser.uid).set({
      'username': newUser.username,
      'email': newUser.email,
      'profilePicture': newUser.profilePicture,
      'bio': newUser.bio, 
      'ownedTrees': newUser.ownedTrees,
      'droplets': newUser.droplets,
    });
    return newUser;
  }



  //we initialize the trees and the tasks of the user
  Future<void> _initializeRelatedData(BuildContext context) async {
    //if (_user.id == 'guest') return;
    await _initializeUserTrees(context);
    await _initializeUserTasks(context);
  }


  //listener for authentication changes (when we sign out bla bla bla)
  void _listenToAuthChanges(BuildContext context) {
    fb_auth.FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      print("Auth state changed. User: ${firebaseUser?.uid}");
      
      //setting loading state during auth transition
      _isLoading = true;
      notifyListeners(); 

      try {
        if (firebaseUser != null /*&& !firebaseUser.isAnonymous*/) {
          _user = await _fetchUserDataFromFirestore(firebaseUser);
          await _initializeRelatedData(context); // ?????? Re-initialize data for the new user
          _startTaskResetTimer(context);
        } else {
          _user = _createEmptyUser();
          _userTrees = [];
          _dailyUserTasks = [];
          _treeProviders = [];
          _taskProviders = [];
          _taskResetTimer?.cancel();
          print("User signed out, data cleared.");
        }
      } catch (e) {
          print("Error during auth state change handling: $e");
          _user = _createEmptyUser(); 
      } finally {
          _isLoading = false; 
          notifyListeners(); 
      }

    });
  }



  Future<void> updateUserBio(String newBio) async {
    //prevent guest users from saving bio to Firestore
    if (_user.id == 'guest') {
        _user.bio = newBio; //update locally for guest
        notifyListeners();
        print("Guest bio updated locally.");
        return;
    }

    //limit bio length 
    final trimmedBio = newBio.length > 150 ? newBio.substring(0, 150) : newBio; 

    if (_user.bio != trimmedBio) {
      _user.bio = trimmedBio;
      notifyListeners(); 
      await _updateUserFirestore({'bio': trimmedBio});
      print("User bio updated in Firestore.");
    } else {
       print("Bio unchanged, skipping update.");
    }

  }




  @override
  void dispose() {
    _taskResetTimer?.cancel();
    super.dispose();
  }





  /*TREES*/

  Future<void> _initializeUserTrees(BuildContext context) async {
    //don't initialize if user is guest
    if (_user.id == 'guest') {
      _userTrees = [];
      _treeProviders = [];
      notifyListeners(); 
      return;
    }

    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    await gardenProvider.dataLoaded;

    List<Tree> foundTrees = [];

    print('(InitTrees) User ID: ${user.id}');
    print('(InitTrees) User\'s owned tree data: ${user.ownedTrees}');
    print('(InitTrees) Available trees in GardenProvider: ${gardenProvider.allAvailableTrees.map((t) => t.id).toList()}',);

    // check if ownedTrees is actually populated
     if (user.ownedTrees.isEmpty) {
       print('(InitTrees) User owns no trees.');
       _userTrees = [];
       _treeProviders = [];
       notifyListeners();
       return;
     }


    for (final ownedTreeData in user.ownedTrees) {
      //ensure map structure is correct
      if (!ownedTreeData.containsKey('treeId')) {
          print('Warning: Invalid owned tree data format: $ownedTreeData');
          continue;
      }
      final treeId = ownedTreeData['treeId'] as String?;
      final initialDropletsUsed = ownedTreeData['dropletsUsed'] as int? ?? 0;
      final initialCurLevel = ownedTreeData['curLevel'] as int? ?? 0;


      if (treeId != null) {
        try {
          final tree = gardenProvider.allAvailableTrees.firstWhere(
            (t) => t.id == treeId);
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
          print('Warning: Tree with ID $treeId from user data not found in catalog.');
        }
      } else {
         print('Warning: Found owned tree data with null treeId.');
      }
    }

    _userTrees = foundTrees;
    _treeProviders = _userTrees.map((tree) => TreeProvider(tree)).toList();
    print('(InitTrees) Found user trees: ${_userTrees.map((t) => t.id).toList()}');
    print('(InitTrees) Created tree providers: ${_treeProviders.length}');
    notifyListeners();
  }


  Future<void> buyTree(BuildContext context, String treeId) async {
    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    await gardenProvider.dataLoaded; 

    final treeToBuy = gardenProvider.allAvailableTrees.firstWhere(
      (tree) => tree.id == treeId,
      orElse: () => throw StateError('Tree with ID $treeId not found in catalog'),
    );

    print('Attempting to buy tree with ID: ${treeToBuy.id}');
    final alreadyOwned = _user.ownedTrees.any( 
      (ownedTree) => ownedTree['treeId'] == treeId,
    );

    if (_user.droplets >= treeToBuy.price && !alreadyOwned) {
      final price = treeToBuy.price; 
 
      takeDroplets(price); 

      //update locally
      final newOwnedTreeData = {
        'treeId': treeToBuy.id,
        'dropletsUsed': 0,
        'curLevel': 0,
      };
      _user.ownedTrees.add(newOwnedTreeData);

      final boughtTreeInstance = Tree(
        id: treeToBuy.id,
        name: treeToBuy.name,
        description: treeToBuy.description,
        species: treeToBuy.species,
        price: treeToBuy.price,
        levels: treeToBuy.levels,
        dropletsUsed: 0, 
        curLevel: 0,     
      );
      _userTrees.add(boughtTreeInstance);
      _treeProviders.add(TreeProvider(boughtTreeInstance));
      notifyListeners();

      if(_user.id != 'guest') { 
        try {
          await _updateUserFirestore({
            'ownedTrees': FieldValue.arrayUnion([newOwnedTreeData]),
            });
          print("Tree purchased successfully and Firestore updated.");
        } catch (e) {
           print('Error updating ownedTrees in Firestore after purchase: $e');
           addDroplets(price); 
           _user.ownedTrees.removeWhere((ot) => ot['treeId'] == treeId);
           _userTrees.removeWhere((tree) => tree.id == treeId);
           _treeProviders.removeWhere((provider) => provider.tree.id == treeId);
           notifyListeners(); 
        }
      } else {
        print('Guest user: Not updating Firestore for tree purchase.');
      }

    } else if (alreadyOwned) {
      print('You already own ${treeToBuy.name}.');
    } else {
      print('Not enough droplets to buy ${treeToBuy.name}.');
    }
  }



  //we need to update things on the cloud too
  Future<void> updateUserTreeInFirestore(Tree updatedTree) async {
    if (_user.id.isEmpty || _user.id == 'guest') return;

    //update locally?

    final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user.id);
    final userData = (await userDocRef.get()).data();
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
  






  /*TASKS*/


  Future<void> _initializeUserTasks(BuildContext context) async {
    await _assignDailyTasks(context);
    _taskProviders = _dailyUserTasks.map((task) => TaskProvider()).toList();
    notifyListeners();
  }



  Future<void> _assignDailyTasks(BuildContext context) async {
    if (_user.id.isEmpty) return;

    final now = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(now);
    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

    final dailyTasksDoc = await dailyTasksDocRef.get();
    final tasksProvider = Provider.of<TaskProvider>(context, listen: false);
    await tasksProvider.dataLoaded;

    List<String> completedTaskIds = [];
    List<Map<String, dynamic>> personalizedTasksMap = [];
    
    if (dailyTasksDoc.exists && dailyTasksDoc.data() != null) {
      if (dailyTasksDoc.data()!.containsKey('personalized_tasks_map')) {
        personalizedTasksMap = List<Map<String, dynamic>>.from(dailyTasksDoc.data()!['personalized_tasks_map'] ?? []);}
      
      if (dailyTasksDoc.data()!.containsKey('completedTasks')) {
        completedTaskIds = List<String>.from(dailyTasksDoc.data()!['completedTasks'] ?? []);}
    }


    //check if the tasks need to be reset
    bool doReset = _tasksNeedReset ||
        !dailyTasksDoc.exists ||
        dailyTasksDoc.data()?['date'] != todayDate ||
        (dailyTasksDoc.data()?['tasks'] as List<dynamic>?)?.isEmpty == true;
    
    if (tasksProvider.allAvailableTasks.isNotEmpty && doReset) {
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

      await dailyTasksDocRef.set({
        'date': todayDate, 
        'tasks': selectedTasks,
      });

      _dailyUserTasks =
          tasksProvider.allAvailableTasks
              .where((task) => selectedTasks.contains(task.id.toString()))
              .toList();

      
      _tasksNeedReset = false;



    } else if (dailyTasksDoc.exists && dailyTasksDoc.data() != null) {
      print("Loading existing daily tasks for $todayDate");
      final taskIdsFromFirestore = List<String>.from(
        dailyTasksDoc.data()!['tasks'] as List<dynamic>? ?? [],
      );

      if (taskIdsFromFirestore.isEmpty) {
         print("Warning: Firestore task list is empty, assigning new tasks.");
         await _assignDailyTasks(context); 
         return; 
      }


      //lookup all available tasks
      final allTasksMap = {
        for (var task in tasksProvider.allAvailableTasks) task.id: task
      };
      for (var pTaskMap in personalizedTasksMap) {
        final pTaskId = pTaskMap['id'] as String;
        if (!allTasksMap.containsKey(pTaskId)) {
          allTasksMap[pTaskId] = Task(
            id: pTaskId,
            description: pTaskMap['description'] ?? 'Personalized Task',
            dropletReward: pTaskMap['dropletReward'] ?? 1,
            creationDate: DateTime.now(), // Or fetch if stored
            isPersonalized: true,
          );
        }
      }


      //build the list in the order from Firestore
      _dailyUserTasks = taskIdsFromFirestore.map((id) {
        final task = allTasksMap[id];
        if (task == null) {
          print("Warning: Task ID $id from Firestore not found in available tasks or personalized map.");
        }
        return task;
      }).whereType<Task>().toList(); 


    } else {
       print("No existing daily tasks document found, assigning new tasks.");
       await _assignDailyTasks(context); //recalling to trigger reset
       return; 
    }


    

    // we check if any of them is completed on Firestore
    for (var task in _dailyUserTasks) {
      task.isCompleted = completedTaskIds.contains(task.id.toString());
      task.isPersonalized = personalizedTasksMap.any((taskMap) => taskMap['id'] == task.id);
    }
    

    notifyListeners();
  }





  // Add a new task to the user's daily tasks
  void addPersonalizedTask(Task task) {

    final personalizedTasksCount = _dailyUserTasks.where((t) => t.isPersonalized).length;

    //check if the limit of 3 personalized tasks is reached
    if (personalizedTasksCount >= 3) {
      print('You can only create up to 3 personalized tasks.');
      return;
    }

    task.isPersonalized = true;
    _dailyUserTasks.add(task);
    notifyListeners();

    //update Firestore if the user is not a guest
    if (_user.id != 'guest') {
      final Map<String, dynamic> personalizedTask = {
        'id': task.id,
        'description': task.description,
        'dropletReward': task.dropletReward
      };

      FirebaseFirestore.instance
          .collection('users')
          .doc(_user.id)
          .collection('daily_tasks')
          .doc('current')
          .update({
            'personalized_tasks_map': FieldValue.arrayUnion([personalizedTask]),
          });
    }
  }


  Future<void> completeTask(Task task) async {
    if (!_dailyUserTasks.any((t) => t.id == task.id)) return;
    
    addDroplets(task.dropletReward);
    final index = _dailyUserTasks.indexWhere((t) => t.id == task.id);
    if (index != -1 && !_dailyUserTasks[index].isCompleted) {
      _dailyUserTasks[index].completeTask();
      notifyListeners();
    }

    if (_user.id != 'guest') { 
      final dailyTasksDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user.id)
          .collection('daily_tasks')
          .doc('current');

      await dailyTasksDocRef.update({'completedTasks': FieldValue.arrayUnion([task.id])});
    } else {
      print('Guest user: Task completed locally.');
    }
  }


  Future<void> unCompleteTask(Task task) async {
    if (!_dailyUserTasks.any((t) => t.id == task.id)) return;

    takeDroplets(task.dropletReward);
    final index = _dailyUserTasks.indexWhere((t) => t.id == task.id);

    if (index != -1 && _dailyUserTasks[index].isCompleted) {
      _dailyUserTasks[index].unCompleteTask();
      notifyListeners();
    }

    if (_user.id != 'guest') { 
      final dailyTasksDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user.id)
          .collection('daily_tasks')
          .doc('current');

      await dailyTasksDocRef.update({'completedTasks': FieldValue.arrayRemove([task.id])});
    } else {
      print('Guest user: Task un-completed locally.');
    }
  }


  void reorderTasks(int oldIndex, int newIndex) {
    final task = _dailyUserTasks.removeAt(oldIndex);
    _dailyUserTasks.insert(newIndex, task);
    notifyListeners();

    //we update Firestore to save the new order
    if (_user.id != 'guest') {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_user.id)
          .collection('daily_tasks')
          .doc('current')
          .update({'tasks': _dailyUserTasks.map((task) => task.id).toList()});
    }
  }


  void removePersonalizedTask(Task task) {
    _dailyUserTasks.removeWhere((t) => t.id == task.id);
    notifyListeners();

    //update Firestore if the user is not a guest
    if (_user.id != 'guest') {
      FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current')

        .get().then((doc) {

          if (doc.exists && doc.data()!.containsKey('personalized_tasks_map')) {
            
            List<String> tasks = List<String>.from(doc.data()!['tasks'] ?? []);
            List<String> completedTasks = List<String>.from(doc.data()!['completedTasks'] ?? []);

            List<Map<String, dynamic>> personalizedTasksMap = 
                List<Map<String, dynamic>>.from(doc.data()!['personalized_tasks_map'] ?? []);
            
            // find matching id
            personalizedTasksMap.removeWhere((taskMap) => taskMap['id'] == task.id);
            tasks.removeWhere((taskId) => taskId == task.id);
            completedTasks.removeWhere((taskId) => taskId == task.id);

            // update Firestore
            FirebaseFirestore.instance
                .collection('users')
                .doc(_user.id)
                .collection('daily_tasks')
                .doc('current')
                .update({
                  'personalized_tasks_map': personalizedTasksMap,
                  'tasks': tasks,
                  'completedTasks': completedTasks,
                });
          }
        }

      );
    }
  }  



  //we need to clear the completed tasks list and the personalized tasks map
  Future<void> _clearTasks(BuildContext context) async {
    if (_user.id.isEmpty) return;

    final dailyTasksDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.id)
        .collection('daily_tasks')
        .doc('current');

    await dailyTasksDocRef.update({
      'completedTasks': FieldValue.delete(),
      'personalized_tasks_map': FieldValue.delete(),
    });

    for (var task in _dailyUserTasks) {
      if (task.isCompleted) task.isCompleted = false;
      if (task.isPersonalized) task.isPersonalized = false;
    }
  }




  void _startTaskResetTimer(BuildContext context) {
    _taskResetTimer?.cancel(); // cancel any existing timer

    // reset on next midnight
    final now = DateTime.now();
    final nextReset = DateTime(now.year, now.month, now.day + 1);
    //final secondsReset = now.add(Duration(seconds: 15));
    //final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _timeUntilNextReset = nextReset.difference(now);

    // we start the timer
    _taskResetTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_timeUntilNextReset.inSeconds <= 0) {
        timer.cancel();
        _tasksNeedReset = true;
        _clearTasks(context);
        _assignDailyTasks(context);
        _startTaskResetTimer(context);
      } else {
        _timeUntilNextReset = nextReset.difference(DateTime.now());
        notifyListeners();
      }
    });

    print(
      'Task reset timer started. Tasks will reset in $_timeUntilNextReset',
    );
  }






  /*GENERAL*/

  void addDroplets(int amount) {
    _user.droplets += amount; //this needs fixing but i dont want to change user class yet
    notifyListeners();
    _updateUserFirestore({'droplets': _user.droplets});
  }

  void takeDroplets(int amount) {
    user.droplets -= amount;
    notifyListeners();
    _updateUserFirestore({'droplets': _user.droplets});
  }

  Future<void> _updateUserFirestore(Map<String, dynamic> data) async {
    if (_user.id.isNotEmpty && _user.id != 'guest') {
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