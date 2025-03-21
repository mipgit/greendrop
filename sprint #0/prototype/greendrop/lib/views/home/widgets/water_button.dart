import 'package:flutter/material.dart';

class WaterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const WaterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text('Water Me!', style: TextStyle(color: Colors.black, fontSize: 18)),
    );
  }
}