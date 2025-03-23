import 'package:flutter/material.dart';
import 'package:greendrop/view_model/droplet_provider.dart';
import 'package:greendrop/views/droplet_counter.dart';
import 'widgets/olive_tree_dialog.dart';
import 'widgets/coming_soon_box.dart';

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
    final provider = DropletProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Garden',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.lightGreen.shade900,
          ),
        ),
        backgroundColor: Colors.green.shade50,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropletCounter(dropletCount: provider?.dropletCount ?? 0),

            const SizedBox(height: 20),

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
                    DropletProvider.of(context)!.hasBoughtTree
                        ? "Thanks for buying me! :)"
                        : "What's for Sale?",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
