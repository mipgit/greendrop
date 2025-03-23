import 'package:flutter/material.dart';

class DropletProvider extends InheritedWidget {
  final int dropletCount;
  final Function(int) updateDroplets;
  final int dropletsUsed;
  final Function(int) updateDropletsUsed;
  final bool hasBoughtTree;
  final Function(bool) updateHasBoughtTree;
  // Store task completion states here
  final List<bool> completedTasks;
  final Function(int, bool) updateTaskCompletion;
  final bool treeGrown; // Add this
  final Function(bool) updateTreeGrown;

  const DropletProvider({
    Key? key,
    required this.dropletCount,
    required this.updateDroplets,
    required this.dropletsUsed,
    required this.updateDropletsUsed,
    required this.hasBoughtTree,
    required this.updateHasBoughtTree,
    required this.completedTasks,
    required this.updateTaskCompletion,
    required this.treeGrown,
    required this.updateTreeGrown,
    required Widget child,
  }) : super(key: key, child: child);

  static DropletProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DropletProvider>();
  }

  @override
  bool updateShouldNotify(DropletProvider oldWidget) {
    return dropletCount != oldWidget.dropletCount ||
        dropletsUsed != oldWidget.dropletsUsed ||
        hasBoughtTree != oldWidget.hasBoughtTree ||
        treeGrown != oldWidget.treeGrown ||
        completedTasks != oldWidget.completedTasks; // Very important to check
  }
}