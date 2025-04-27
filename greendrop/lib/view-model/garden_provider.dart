import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';

class GardenProvider with ChangeNotifier{

  List<Tree> _allAvailableTrees = [];
  bool _isLoading = true; 
  String? _error; 
  final Completer<void> _dataLoadedCompleter = Completer<void>(); // Add a Completer


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
        final data = doc.data();
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


}