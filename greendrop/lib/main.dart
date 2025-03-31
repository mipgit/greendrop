import 'package:flutter/material.dart';
import 'package:greendrop/view/navigation_view.dart';

void main() {

  //firebase things before running App

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenDrop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen.shade600,
        ),
      ),
      home: const NavigationView(),
    );
  }
}
