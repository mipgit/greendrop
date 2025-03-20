import 'package:flutter/material.dart';
import 'home_page.dart';
import 'droplet_provider.dart';

void main() {
  runApp(DropletApp());
}

class DropletApp extends StatefulWidget {
  @override
  _DropletAppState createState() => _DropletAppState();
}

class _DropletAppState extends State<DropletApp> {
  int dropletCount = 30;
  int dropletsUsed = 0; // New persistent counter

  void updateDroplets(int newCount) {
    setState(() {
      dropletCount = newCount;
    });
  }

  void updateDropletsUsed(int newCount) {
    setState(() {
      dropletsUsed = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropletProvider(
      dropletCount: dropletCount,
      updateDroplets: updateDroplets,
      dropletsUsed: dropletsUsed, // Provide this to the app
      updateDropletsUsed: updateDropletsUsed,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}