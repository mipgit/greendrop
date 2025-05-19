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

    //Community Service Tasks
    {
      'description': 'Participated in a local clean-up event',
      'dropletReward': 5,
      'category': 'Community Service',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Donated clothes or items to charity',
      'dropletReward': 4,
      'category': 'Community Service',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Helped a neighbor with yard work or gardening',
      'dropletReward': 3,
      'category': 'Community Service',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Volunteered at a local animal shelter',
      'dropletReward': 5,
      'category': 'Community Service',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Participated in a tree planting event',
      'dropletReward': 4,
      'category': 'Community Service',
      'creationDate': Timestamp.now(),
    },


    // Waste Reduction Tasks
    {
      'description': 'Recycled ',
      'dropletReward': 1,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Used a reusable water bottle instead of plastic bottles',
      'dropletReward': 1,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Brought your own shopping bags to the grocery store',
      'dropletReward': 2,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Avoided single-use plastic utensils',
      'dropletReward': 1,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Planned meals and used leftover ingredients to minimize food waste',
      'dropletReward': 4,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Stored food properly and used leftovers before they spoiled',
      'dropletReward': 3,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Composted food scraps and yard waste',
      'dropletReward': 4,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Used cloth napkins instead of paper ones',
      'dropletReward': 1,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Participated in a local recycling program',
      'dropletReward': 2,
      'category': 'Waste Reduction',
      'creationDate': Timestamp.now(),
    },

    
    // Sustainable Transport Tasks
    {
      'description': 'Walked or cycled for short trips instead of driving',
      'dropletReward': 2,
      'category': 'Sustainable Transport',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Used public transportation',
      'dropletReward': 2,
      'category': 'Sustainable Transport',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Carpooled with colleagues or friends',
      'dropletReward': 2,
      'category': 'Sustainable Transport',
      'creationDate': Timestamp.now(),
    },

 


    // Energy Conservation
    {
      'description': 'Turned off lights when leaving a room',
      'dropletReward': 1,
      'category': 'Energy Conservation',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Unpluged electronic devices when not in use',
      'dropletReward': 2,
      'category': 'Energy Conservation',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Used natural lighting instead of artificial when possible',
      'dropletReward': 2,
      'category': 'Energy Conservation', 
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Used energy-efficient appliances',
      'dropletReward': 3,
      'category': 'Energy Conservation',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Set thermostat to an energy-saving temperature',
      'dropletReward': 2,
      'category': 'Energy Conservation',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Used a clothesline instead of a dryer',
      'dropletReward': 3,
      'category': 'Energy Conservation',
      'creationDate': Timestamp.now(),
    },

    

    // Water Conservation
    {
      'description': 'Took shorter shower (under 5 minutes)',
      'dropletReward': 2,
      'category': 'Water Conservation',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Turned off water while brushing teeth',
      'dropletReward': 1,
      'category': 'Water Conservation',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Checked for and fixed any leaky faucets',
      'dropletReward': 2,
      'category': 'Water Conservation',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Colected rain water',
      'dropletReward': 3,
      'category': 'Water Conservation',
      'creationDate': Timestamp.now(),
    },
    {
      'description': 'Watered plants with rain water',
      'dropletReward': 2,
      'category': 'Water Conservation',
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