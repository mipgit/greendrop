import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/firebase_options.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting populate_trees script...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /* 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final treesCollection = FirebaseFirestore.instance.collection('trees');

  final treesSnapshot = await treesCollection.get();
  for (final doc in treesSnapshot.docs) {
    await doc.reference.delete();
    print('Deleted tree with ID: ${doc.id}');
  } 
  */

 

  final trees = [
    {
      'name': 'Oak',
      'description': 'A sturdy oak.',
      'species': 'Oak Tree',
      'price': 60,
      'levels': [
        {
          'levelNumber': 0,
          'levelPicture': 'assets/Sprout2.png',
          'requiredDroplets': 0,
        },
        {
          'levelNumber': 1,
          'levelPicture': 'assets/Oak1.png',
          'requiredDroplets': 15,
        },
        {
          'levelNumber': 2,
          'levelPicture': 'assets/Oak2.png',
          'requiredDroplets': 30,
        },
      ],
    },
    {
      'name': 'Palm',
      'description': 'A carefree palm.',
      'species': 'Palm Tree',
      'price': 45,
      'levels': [
        {
          'levelNumber': 0,
          'levelPicture': 'assets/Sprout2.png',
          'requiredDroplets': 0,
        },
        {
          'levelNumber': 1,
          'levelPicture': 'assets/Palm1.png',
          'requiredDroplets': 15,
        },
        {
          'levelNumber': 2,
          'levelPicture': 'assets/Palm2.png',
          'requiredDroplets': 30,
        },
      ],
    },
    {
      'name': 'Oli',
      'description': 'A happy olive tree.',
      'species': 'Olive Tree',
      'price': 30,
      'levels': [
        {
          'levelNumber': 0,
          'levelPicture': 'assets/Sprout2.png',
          'requiredDroplets': 0,
        },
        {
          'levelNumber': 1,
          'levelPicture': 'assets/olive-tree.png',
          'requiredDroplets': 10,
        },
        {
          'levelNumber': 2,
          'levelPicture': 'assets/Olive2.png',
          'requiredDroplets': 20,
        },
      ],
    },
    {
      'name': 'Pine',
      'description': 'A tall pine tree.',
      'species': 'Pine Tree',
      'price': 50,
      'levels': [
        {
          'levelNumber': 0,
          'levelPicture': 'assets/Sprout2.png',
          'requiredDroplets': 0,
        },
        {
          'levelNumber': 1,
          'levelPicture': 'assets/Pine1.png',
          'requiredDroplets': 20,
        },
        {
          'levelNumber': 2,
          'levelPicture': 'assets/Pine2.png',
          'requiredDroplets': 40,
        },
      ],
    },
  ];

  final treesCollection = FirebaseFirestore.instance.collection('trees');

  for (final tree in trees) {
    try {
      // Skip if tree with the same species already exists
      final query = await treesCollection
          .where('species', isEqualTo: tree['species'])
          .get();
      if (query.docs.isNotEmpty) {
        print('"${tree['species']}" already exists. Skipping.');
        continue;
      }

      final docRef = await treesCollection.add(tree);
      print('Added tree with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding tree: $e');
    }
  }

  exit(0);
}
  /*
  for (final tree in trees) {
    try {
      final docRef = await treesCollection.add(tree);
      print('Added tree with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding tree: $e');
    }
  }
  */
