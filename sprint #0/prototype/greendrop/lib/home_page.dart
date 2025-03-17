import 'package:flutter/material.dart';
import 'dart:io'; // Required to close the app
import 'todo_screen.dart'; // Import TodoScreen for navigation

void main() => runApp(MyApp());  // Ensure the HomePage is the main entry point

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int dropletCount = 31;
  int _selectedIndex = 0;

  void waterTree() {
    if (dropletCount > 0) {
      setState(() {
        dropletCount--;
      });
    }
  }

  void _showExitPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit GreenDrop", style: TextStyle(color: Colors.green.shade700)),
        content: Text("Are you sure you want to close the app?", style: TextStyle(color: Colors.green.shade700)),
        actions: [
          TextButton(
            onPressed: () => exit(0), // Closes the app
            child: Text("Yes, I do", style: TextStyle(color: Colors.green.shade700)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Dismisses pop-up
            child: Text("No, I don't", style: TextStyle(color: Colors.green.shade700)),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: Text('GreenDrop', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: _selectedIndex == 0 // Only show back arrow on HomePage
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _showExitPopup, // Triggers exit confirmation pop-up
              )
            : null,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.account_circle, color: Colors.white),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade400, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.water_drop, color: Colors.green.shade700),
                            SizedBox(width: 8),
                            Text(
                              '$dropletCount',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/treetasker.png', height: 450),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade200,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade400, width: 2),
                        ),
                        child: ElevatedButton(
                          onPressed: waterTree,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade200,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                          ),
                          child: Text('Water Me!', style: TextStyle(color: Colors.black, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            )
          : TodoScreen(), // Navigate to Tasks page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green.shade100,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Tasks',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}