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

  void updateDroplets(int newCount) {
    setState(() {
      dropletCount = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropletProvider(
      dropletCount: dropletCount,
      updateDroplets: updateDroplets,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),  // HomePage should be the starting widget
      ),
    );
  }
}