import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greendrop/view_model/droplet_provider.dart';
import 'package:greendrop/views/droplet_counter.dart';
import 'package:greendrop/views/profile/profile_page_view.dart';
import 'widgets/water_button.dart';
import 'widgets/tree_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  bool hasClickedWaterMe = false;
  int dropletsUntilGrowth = 5;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (DropletProvider.of(context)?.treeGrown ?? false) {
      dropletsUntilGrowth = 0;
    }
  }

  void waterTree() {
    final provider = DropletProvider.of(context);
    if (provider != null && provider.dropletCount > 0) {
      provider.updateDroplets(provider.dropletCount - 1);
      provider.updateDropletsUsed(provider.dropletsUsed + 1);

      setState(() {
        hasClickedWaterMe = true;
        if (!provider.treeGrown) {
          dropletsUntilGrowth--;
          if (dropletsUntilGrowth <= 0) {
            _growTree();
          }
        }
      });
    } else {
      setState(() {
        hasClickedWaterMe = true;
      });
    }
  }

  void _growTree() {
    final provider = DropletProvider.of(context);
    provider?.updateTreeGrown(true);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                Colors.green.shade100, // Apply the app's color scheme
            title: const Text(
              "Congrats!",
              style: TextStyle(color: Colors.grey),
            ),
            content: const Text(
              "Look at how much the tree has grown!",
              style: TextStyle(color: Colors.green),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Awesome!",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ), // Match the app's style
          ),
    );
  }

  void _resetProgress() {
    final provider = DropletProvider.of(context);
    provider?.updateDropletsUsed(0);
    provider?.updateHasBoughtTree(false);
    provider?.updateDroplets(30);
    provider?.updateTreeGrown(false); // Reset treeGrown to false
    setState(() {
      dropletsUntilGrowth = 5;
    });
    for (int i = 0; i < provider!.completedTasks.length; i++) {
      provider.updateTaskCompletion(i, false);
    }
    Navigator.of(context).pop();
  }

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Reset Progress",
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Do you really want to reset your progress? This cannot be undone!",
              style: TextStyle(color: Colors.green.shade800),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "No, I don't",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: _resetProgress,
                child: Text(
                  "Yes, I do",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
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
      builder:
          (context) => AlertDialog(
            title: Text(
              "Exit GreenDrop",
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
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
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: Text(
                  "Yes, I do",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.green.shade100,
          ),
    );
  }

  void _showNoDropletsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You don\'t have any droplets!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = DropletProvider.of(context);

    if (provider?.dropletCount == 0 && hasClickedWaterMe) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoDropletsMessage();
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: Text(
          'GreenDrop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.exit_to_app, color: Colors.lightGreen.shade900),
          onPressed: _confirmExit,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Colors.lightGreen.shade900,
                size: 25,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropletCounter(dropletCount: provider?.dropletCount ?? 0),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.lightGreen.shade900,
                    ),
                    onPressed: _confirmResetProgress,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Tree and Droplet Counter Box
                  TreeBox(
                    treeGrown: provider?.treeGrown ?? false,
                    dropletsUntilGrowth: dropletsUntilGrowth,
                    dropletsUsed: provider?.dropletsUsed ?? 0,
                  ),
                  WaterButton(onPressed: waterTree),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
