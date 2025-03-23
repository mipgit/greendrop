import 'package:flutter/material.dart';

class TreeBox extends StatelessWidget {
  final bool treeGrown;
  final int dropletsUntilGrowth;
  final int dropletsUsed;

  const TreeBox({
    Key? key,
    required this.treeGrown,
    required this.dropletsUntilGrowth,
    required this.dropletsUsed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      width: double.infinity,
      height: screenHeight * 0.50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Eucalyptus",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            !treeGrown
                ? 'Remaining droplets until grown: $dropletsUntilGrowth'
                : 'Droplets used: $dropletsUsed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter, // Always align to bottom
              child: Image.asset(
                treeGrown ? 'assets/tree.png' : 'assets/sprout.png',
                height: treeGrown ? 300 : 100, // Adjusted image heights
                fit:
                    BoxFit
                        .contain, // Ensure the image fits within the available space
              ),
            ),
          ),
        ],
      ),
    );
  }
}
