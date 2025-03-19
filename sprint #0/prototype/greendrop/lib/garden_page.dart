import 'package:flutter/material.dart';
import 'package:greendrop/home_page.dart';
import 'package:greendrop/todo_screen.dart';

class GardenPage extends StatefulWidget {
  final int dropletCount;
  final Function(int) updateDropletCount;

  GardenPage({required this.dropletCount, required this.updateDropletCount});

  @override
  _GardenPageState createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  bool hasBoughtTree = false;

  void _buyTree() {
  if (widget.dropletCount >= 30 && !hasBoughtTree) {
    setState(() {
      widget.updateDropletCount(widget.dropletCount - 30);
      hasBoughtTree = true;
    });
  } else {
    // Show Snackbar if there are not enough droplets
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Not enough droplets!'),
        backgroundColor: Colors.red.shade600,
        duration: Duration(seconds: 2), // Adjust duration to control how long it stays visible
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Garden', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green.shade100,
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: hasBoughtTree
              ? Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.green.shade400, width: 2),
                  ),
                  child: Text(
                    "No trees for sale! We apologize!",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/olive_tree.png', height: 250), // Resized image
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Oli",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          Text(
                            "Olive Tree",
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.green.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "I'm a tough, slow-growing tree with silvery-green leaves and olives used for high-quality olive oil. I thrive in dry, rocky soils and can withstand harsh conditions.",
                            style: TextStyle(fontSize: 14.0, color: Colors.green.shade800),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.water_drop, color: Colors.green.shade700),
                              SizedBox(width: 4),
                              Text(
                                "30",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _buyTree,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade400,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Buy",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Highlight the Garden tab
        backgroundColor: Colors.green.shade300,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TodoScreen()),
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