import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:greendrop/model/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _allAvailableTasks = [];
  bool _isLoading = true;
  String? _error;
  Completer<void> _dataLoadedCompleter = Completer<void>();

  List<Task> get allAvailableTasks => _allAvailableTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TaskProvider() {
    _loadTasksFromFirestore();
  }

  Future<void> _loadTasksFromFirestore() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('tasks').get();
      _allAvailableTasks =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Task(
              id: doc.id,
              description: data['description'] as String? ?? '',
              dropletReward: data['dropletReward'] as int? ?? 0,
              creationDate:
                  (data['creationDate'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
            );
          }).toList();
      _dataLoadedCompleter.complete();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load tasks: $e';
      _dataLoadedCompleter.completeError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> get dataLoaded => _dataLoadedCompleter.future; 

}
