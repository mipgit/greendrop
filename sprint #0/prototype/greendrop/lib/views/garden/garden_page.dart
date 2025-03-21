import 'package:flutter/material.dart';
import 'package:greendrop/view_model/droplet_provider.dart';
import 'widgets/olive_tree_dialog.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({Key? key}) : super(key: key);

  void _showOliveTreeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const OliveTreeDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green.shade100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showOliveTreeDialog(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    DropletProvider.of(context)!.hasBoughtTree ? "Thanks for buying me! :)" : "What's for Sale?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const ComingSoonBox(),
            const SizedBox(height: 16),
            const ComingSoonBox(),
            const SizedBox(height: 16),
            const ComingSoonBox(),
          ],
        ),
      ),
    );
  }
}


class ComingSoonBox extends StatelessWidget {
  const ComingSoonBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1), // Slight black color
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          "Coming Soon...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}