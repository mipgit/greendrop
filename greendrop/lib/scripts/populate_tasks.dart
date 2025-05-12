import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/firebase_options.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting populate_tasks script...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final tasks = [
    {
      'description': 'Volunteered for community clean-ups',
      'dropletReward': 3,
      'category': 'Environment',
      'creationDate': Timestamp.now(),
    },

    {
      'description': 'Reduced food waste',
      'dropletReward': 1,
      'category': 'Environment',
      'creationDate': Timestamp.now(),
    },

    {
      'description': 'Used public transportation, walked or rode the bike',
      'dropletReward': 2,
      'category': 'Environment',
      'creationDate': Timestamp.now(),
    },

    {
      'description': 'Recycled',
      'dropletReward': 1,
      'category': 'Environment',
      'creationDate': Timestamp.now(),
    },

    {
      'description': 'Turned off lights when not being used',
      'dropletReward': 1,
      'category': 'Environment',
      'creationDate': Timestamp.now(),
    },

    {
      'description': 'Participated in a tree planting event',
      'dropletReward': 4,
      'category': 'Environment',
      'creationDate': Timestamp.now(),
    },

  ];

  final tasksCollection = FirebaseFirestore.instance.collection('tasks');

  for (final task in tasks) {
    try {
      final query = await tasksCollection.where('description', isEqualTo: task['description']).get();
      if (query.docs.isNotEmpty) {
        print('Task "${task['description']}" already exists. Skipping.');
        continue;
      }
      final docRef = await tasksCollection.add(task);
      print('Added task with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  exit(0);
}