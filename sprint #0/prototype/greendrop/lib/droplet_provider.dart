import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

class DropletProvider extends InheritedWidget {
  final int dropletCount;
  final Function(int) updateDroplets;
  final int dropletsUsed; // New variable
  final Function(int) updateDropletsUsed; // New function

  const DropletProvider({
    Key? key,
    required this.dropletCount,
    required this.updateDroplets,
    required this.dropletsUsed,
    required this.updateDropletsUsed,
    required Widget child,
  }) : super(key: key, child: child);

  static DropletProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DropletProvider>();
  }

  @override
  bool updateShouldNotify(DropletProvider oldWidget) {
    return dropletCount != oldWidget.dropletCount ||
           dropletsUsed != oldWidget.dropletsUsed;
  }
}