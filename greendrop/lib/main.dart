import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/navigation_view.dart';
import 'package:provider/provider.dart';

void main() {

  //firebase things before running App

  runApp(
    ChangeNotifierProvider( // wrap the app in the user provider
      create: (context) => UserProvider(),
      child: const GreenDropApp(),
    ),
  );
}

class GreenDropApp extends StatelessWidget {
  const GreenDropApp({super.key});

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
