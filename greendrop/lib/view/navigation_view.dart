import 'package:flutter/material.dart';
import 'package:greendrop/view/garden/garden_view.dart';
import 'package:greendrop/view/home/home_view.dart';
import 'package:greendrop/view/tasks/tasks_view.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    const GardenView(), // Use GardenPage for index 0
    const HomeView(), // Use HomePage for index 1
    const TasksView(), // Use TasksPage for index 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GreenDrop'), centerTitle: true),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,

        destinations: [
          NavigationDestination(icon: Icon(Icons.sunny), label: 'Garden'),
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}
