import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/garden/garden_view.dart';
import 'package:greendrop/view/home/home_view.dart';
import 'package:greendrop/view/tasks/tasks_view.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/navbar/droplet_counter.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    const GardenView(),
    const HomeView(),
    const TasksView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1; // Index 1 is where your HomeView is in _widgetOptions
                });
              },
              child: const Text(
                'GreenDrop',
                style: TextStyle(fontSize: 30.0),
              ),
            ),
            centerTitle: false,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
              ),
              Positioned(
                top: 10.0,
                right: 25.0,
                child: const DropletCounter(),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.sunny), label: 'Garden'),
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                icon: Icon(Icons.task_alt_outlined),
                label: 'Tasks',
              ),
            ],
          ),
        );
      },
    );
  }
}