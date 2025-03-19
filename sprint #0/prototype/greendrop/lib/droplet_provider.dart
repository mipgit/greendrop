import 'package:flutter/material.dart';

class DropletProvider extends InheritedWidget {
  final int dropletCount;
  final Function(int) updateDroplets;

  const DropletProvider({
    Key? key,
    required this.dropletCount,
    required this.updateDroplets,
    required Widget child,
  }) : super(key: key, child: child);

  static DropletProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DropletProvider>();
  }

  @override
  bool updateShouldNotify(DropletProvider oldWidget) {
    return oldWidget.dropletCount != dropletCount;
  }
}
