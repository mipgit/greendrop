import 'package:flutter/material.dart';

class DropletRewardBadge extends StatelessWidget {
  final int reward;

  const DropletRewardBadge({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$reward',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(width: 4.0),
          Icon(
            Icons.water_drop,
            size: 16.0,
            color: Colors.green[700],
          ),
        ],
      ),
    );
  }
}