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
            backgroundColor: Colors.transparent,
            title: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1; 
                });
              },
              child: const Text(
                'GreenDrop',
                style: TextStyle(fontSize: 30.0),
              ),
            ),
            centerTitle: false,
            actions: const [ 
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: DropletCounter(),
              ),
            ],
          ),
          body: Padding( // Add padding to the top of the body
            padding: const EdgeInsets.only(top: 10.0), // Adjust this value as needed
            child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              elevation: 3.0,
              borderRadius: BorderRadius.circular(30.0),
              color: null, // Or any background color you prefer
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: NavigationBar(
                  backgroundColor: Colors.transparent, // Make the NavigationBar transparent
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.local_florist_rounded), label: 'Garden'),
                    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
                    NavigationDestination(icon: Icon(Icons.check_box), label: 'Tasks'),
                  ],
                ),
              ),
            ),
          ),
          
        );
      },
    );
  }
}