import 'package:flutter/material.dart';

class DropletCounter extends StatelessWidget {
  final int dropletCount;

  const DropletCounter({Key? key, required this.dropletCount})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Align to the left
      crossAxisAlignment: CrossAxisAlignment.center, // Align vertically
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ), //REDO THIS PADDING THING
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.water_drop, size: 30, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                '$dropletCount',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 4, 59, 7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
