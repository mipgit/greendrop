import 'package:flutter/material.dart';
import 'home_page.dart';

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
  int dropletCount = 0;

  void _toggleTask(int index) {
    setState(() {
      completed[index] = !completed[index];
      if (completed[index]) {
        dropletCount++;
      } else {
        dropletCount = dropletCount > 0 ? dropletCount - 1 : 0;
      }
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Eco Tasks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ), // No back arrow here
      body: Container(
        color: Colors.green.shade100,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
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
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.green.shade400, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    "Each successful task provides a droplet for your tree. Keep going!",
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Droplet Count: $dropletCount",
                    style: TextStyle(fontSize: 18.0, color: Colors.green.shade900, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.green.shade100,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Tasks'),
        ],
        onTap: _onBottomNavTapped,
      ),
    );
  }
}