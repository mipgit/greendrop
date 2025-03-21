import 'package:flutter/material.dart';
import 'package:greendrop/view_model/droplet_provider.dart';
import 'package:greendrop/views/garden/garden_page.dart';
import 'package:greendrop/views/home/home_page.dart';
import 'package:greendrop/views/tasks/todo_screen.dart';
import 'package:greendrop/widgets/navigation_bar';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  runApp(GreenDropApp(prefs: prefs));
}

class GreenDropApp extends StatelessWidget {
  final SharedPreferences prefs;
  const GreenDropApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenDrop',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainScreen(prefs: prefs),
    );
  }
}

class MainScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const MainScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Start on the Home screen

  late int dropletCount;
  late int dropletsUsed;
  late bool hasBoughtTree;
  late bool treeGrown;
  // Task Completion Status
  late List<bool> completedTasks;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    dropletCount = widget.prefs.getInt('dropletCount') ?? 30;
    dropletsUsed = widget.prefs.getInt('dropletsUsed') ?? 0;
    hasBoughtTree = widget.prefs.getBool('hasBoughtTree') ?? false;
    treeGrown = widget.prefs.getBool('treeGrown') ?? false;

    // Load task completion
    completedTasks = List<bool>.from(
        (widget.prefs.getStringList('completedTasks') ?? List.filled(5, 'false'))
            .map((e) => e == 'true')); // Default to all tasks incomplete

    setState(() {}); // Trigger rebuild after loading
  }

  Future<void> _saveData() async {
    await widget.prefs.setInt('dropletCount', dropletCount);
    await widget.prefs.setInt('dropletsUsed', dropletsUsed);
    await widget.prefs.setBool('hasBoughtTree', hasBoughtTree);
    await widget.prefs.setBool('treeGrown', treeGrown);

    // Save Task completion
    await widget.prefs.setStringList(
        'completedTasks', completedTasks.map((e) => e.toString()).toList());
  }

  void updateDroplets(int newCount) {
    setState(() {
      dropletCount = newCount;
      _saveData();
    });
  }

  void updateDropletsUsed(int newCount) {
    setState(() {
      dropletsUsed = newCount;
      _saveData();
    });
  }

  void updateHasBoughtTree(bool newValue) {
    setState(() {
      hasBoughtTree = newValue;
      _saveData();
    });
  }

  void updateTreeGrown(bool newValue) {
    setState(() {
      treeGrown = newValue;
      _saveData();
    });
  }

  void updateTaskCompletion(int index, bool newValue) {
    setState(() {
      completedTasks[index] = newValue;
      _saveData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropletProvider(
      dropletCount: dropletCount,
      updateDroplets: updateDroplets,
      dropletsUsed: dropletsUsed,
      updateDropletsUsed: updateDropletsUsed,
      hasBoughtTree: hasBoughtTree,
      updateHasBoughtTree: updateHasBoughtTree,
      completedTasks: completedTasks,
      updateTaskCompletion: updateTaskCompletion,
      treeGrown: treeGrown,
      updateTreeGrown: updateTreeGrown,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            GardenScreen(), // Index 0: Garden
            HomeScreen(), // Index 1: Home
            TaskScreen(), // Index 2: Tasks
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}