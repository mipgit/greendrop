import 'package:flutter/material.dart';
import 'package:greendrop/droplet_provider.dart';
import 'garden_page.dart'; // Import Garden Page
import 'home_page.dart'; // Import Home Page

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<String> tasks = [
    "Use a reusable water bottle.",
    "Turn off lights when not in use.",
    "Recycle paper and plastics.",
    "Use public transportation or bike.",
    "Reduce food waste."
  ];

  List<bool> completed = List.filled(5, false);
  int _currentIndex = 1; // Set the initial index to 1 (Tasks page)

  void _toggleTask(int index) {
    final provider = DropletProvider.of(context);
    if (provider != null) {
      setState(() {
        completed[index] = !completed[index];
        int newCount = provider.dropletCount + (completed[index] ? 1 : -1);
        provider.updateDroplets(newCount < 0 ? 0 : newCount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = DropletProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Eco Tasks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green.shade100,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Droplet Count: ${provider?.dropletCount ?? 0}",
              style: TextStyle(fontSize: 18.0, color: Colors.green.shade900, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.green.shade400, width: 2),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: completed[index],
                          onChanged: (bool? value) {
                            _toggleTask(index);
                          },
                          activeColor: Colors.green.shade700,
                        ),
                        title: Text(
                          tasks[index],
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Use _currentIndex to manage the current index
        backgroundColor: Colors.green.shade300,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index on tap
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            // Stay on the Tasks page, no action needed
          } else if (index == 2) {
            Navigator.pushReplacement(
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