import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';

class GardenProvider with ChangeNotifier{

  List<Tree> _allAvailableTrees = [];
  bool _isLoading = true; 
  String? _error; 
  Completer<void> _dataLoadedCompleter = Completer<void>(); // Add a Completer


  List<Tree> get allAvailableTrees => _allAvailableTrees;
  bool get isLoading => _isLoading;
  String? get error => _error;


  GardenProvider() {
   _loadTreesFromFirestore();
  }


  Future<void> _loadTreesFromFirestore() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('trees').get();
      _allAvailableTrees = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final levelsData = data['levels'] as List<dynamic>? ?? [];
        final levels = levelsData.map((levelData) {
          return Level(
            levelNumber: levelData['levelNumber'] as int? ?? 0,
            requiredDroplets: levelData['requiredDroplets'] as int? ?? 0,
            levelPicture: levelData['levelPicture'] as String? ?? '',
          );
        }).toList();

        return Tree(
          id: doc.id, 
          name: data['name'] as String? ?? '',
          description: data['description'] as String? ?? '',
          species: data['species'] as String? ?? '',
          price: data['price'] as int? ?? 0,
          levels: levels,
          dropletsUsed: 0,
          curLevel: 0, 
        );
      }).toList();
      print('GardenProvider: Successfully loaded ${_allAvailableTrees.length} trees.');
       _dataLoadedCompleter.complete();
    } catch (e) {
       _error = e.toString();
      print('GardenProvider: Error loading trees: $e');
      _dataLoadedCompleter.completeError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    } 
  }


  Future<void> get dataLoaded => _dataLoadedCompleter.future; // Expose the Future



  void _oldLoader()  {

      //_isLoading = true;
      notifyListeners();

      try {
        // TO DO: firebase database connection

        // por agora, hardcoded
        _allAvailableTrees = [
          Tree(
            id: 'a', name: 'Oli', description: 'A happy olive tree.', species: 'Olive Tree', price: 30, 
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png'),
              Level(levelNumber: 1, requiredDroplets: 10, levelPicture: 'assets/olive-tree.png'),
              Level(levelNumber: 2, requiredDroplets: 30, levelPicture: 'assets/tree.png')
            ],
            dropletsUsed: 0, curLevel: 0,
          ),
          Tree(
            id: 'b', name: 'Palm', description: 'A carefree palm.', species: 'Palm Tree', price: 45,
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png'),
              Level(levelNumber: 1, requiredDroplets: 20, levelPicture: 'assets/palms.png'),
            ],
            dropletsUsed: 0, curLevel: 0,
          ),
          Tree(
            id: 'c', name: 'Oak', description: 'A sturdy oak.', species: 'Oak Tree', price: 60, 
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png'),
              Level(levelNumber: 1, requiredDroplets: 30, levelPicture: 'assets/oak.png'),
            ],
            dropletsUsed: 0, curLevel: 0,
          ),
        ];
        //_isLoading = false;
        notifyListeners();
      } catch (e) {
        //_isLoading = false;
        //_error = 'Failed to load tree data: $e';
        notifyListeners();
      }
  }

  // fot later : optional methods for filtering, sorting, searching
}