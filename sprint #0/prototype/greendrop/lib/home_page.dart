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
  bool hasClickedWaterMe = false; // Track if the Water Me button was clicked

  void waterTree() {
    final provider = DropletProvider.of(context);
    if (provider != null && provider.dropletCount > 0) {
      provider.updateDroplets(provider.dropletCount - 1);
      provider.updateDropletsUsed(provider.dropletsUsed + 1); // Update global count
      setState(() {
        hasClickedWaterMe = true; // Set flag to true once Water Me is clicked
      });
    } else {
      setState(() {
        hasClickedWaterMe = true; // Set flag to true even if no droplets are available
      });
    }
  }

  void _resetProgress() {
    final provider = DropletProvider.of(context);
    provider?.updateDropletsUsed(0);  // Reset the droplets used counter to 0 if provider is not null
    Navigator.of(context).pop();  // Close the dialog
  }

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Reset Progress",
          style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Do you really want to reset your progress on this tree? This cannot be undone!",
          style: TextStyle(color: Colors.green.shade800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog without resetting
            child: Text(
              "No, I don't",
              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: _resetProgress, // Reset progress if 'Yes' is clicked
            child: Text(
              "Yes, I do",
              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        backgroundColor: Colors.green.shade100,
      ),
    );
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
        backgroundColor: Colors.green.shade100,
      ),
    );
  }

  void _showNoDropletsMessage() {
    // Show the SnackBar after the widget is fully built
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You don\'t have any droplets!'),
        backgroundColor: Colors.red.shade600,
        duration: Duration(seconds: 2), // Duration for how long the message stays visible
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = DropletProvider.of(context);

    // Show the no droplets message only if Water Me button was clicked and no droplets are available
    if (provider?.dropletCount == 0 && hasClickedWaterMe) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoDropletsMessage();  // Show the SnackBar after the widget has finished building
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: Text('GreenDrop', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _confirmExit, // Exit confirmation
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white), // Reset icon
            onPressed: _confirmResetProgress, // Show the reset confirmation dialog
          ),
        ],
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/treetasker.png', height: 450),
                SizedBox(height: 16),

                // Add the Water Me button above the Droplets Used counter
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

                SizedBox(height: 16), // Space between the button and the counter

                Text(
                  'Droplets Used: ${provider?.dropletsUsed ?? 0}', // Using the provider's dropletsUsed
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.green.shade300,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TodoScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GardenPage(
                  dropletCount: provider?.dropletCount ?? 0,
                  updateDropletCount: provider?.updateDroplets ?? (int count) {},
                ),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Garden'),
        ],
      ),
    );
  }
}