import 'package:flutter/material.dart';
import 'package:greendrop/view_model/droplet_provider.dart';

class OliveTreeDialog extends StatelessWidget {
  const OliveTreeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.green.shade100,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensure it takes up minimal space
          children: [
            Image.asset(
              'assets/olive-tree.png',
              height: 120, // Slightly larger image
            ),
            const SizedBox(height: 16),
            const Text(
              "Olive Tree",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "I’m a tough, slow-growing tree with silvery-green leaves and olives used for high-quality olive oil. I thrive in dry, rocky soils and can withstand harsh conditions.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _buyTree(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Buy '),
                      Icon(Icons.water_drop, size: 20, color: Colors.green), // Green droplet icon
                      Text(' 30'), // Cost
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Go Back",
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  void _buyTree(BuildContext context) {
    final provider = DropletProvider.of(context);
    if (provider != null && provider.dropletCount >= 30 && !provider.hasBoughtTree) {
      provider.updateDroplets(provider.dropletCount - 30);
      provider.updateHasBoughtTree(true);
      Navigator.of(context).pop(); // Close the dialog after buying
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough droplets or already purchased!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}