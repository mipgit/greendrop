import 'package:flutter/material.dart';

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