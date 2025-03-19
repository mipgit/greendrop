import 'package:flutter/material.dart';
import 'package:greendrop/droplet_provider.dart';
import 'dart:io'; // For closing the app
import 'todo_screen.dart';
import 'garden_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void waterTree() {
    final provider = DropletProvider.of(context);
    if (provider != null && provider.dropletCount > 0) {
      provider.updateDroplets(provider.dropletCount - 1);
    }
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Exit GreenDrop",
          style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to close the app?",
          style: TextStyle(color: Colors.green.shade800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "No, I don't",
              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: Text(
              "Yes, I do",
              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        backgroundColor: Colors.green.shade100, // Light green background
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = DropletProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: Text('GreenDrop', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _confirmExit, // Exit confirmation
        ),
      ),
      body: Column(
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
                        '${provider?.dropletCount ?? 0}',
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
                ElevatedButton(
                  onPressed: waterTree,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade200,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Water Me!', style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.green.shade300, // ✅ Same color scheme
        selectedItemColor: Colors.white, // ✅ White text
        unselectedItemColor: Colors.white70, // ✅ Light white for unselected
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TodoScreen()),
            );
          } else if (index == 2) {  // Add a check for the new tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GardenPage(
                  dropletCount: provider?.dropletCount ?? 0, // Pass droplet count
                  updateDropletCount: provider?.updateDroplets ?? (int count) {},
                ),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Garden'),  // Add Garden tab
        ],
      ),
    );
  }
}