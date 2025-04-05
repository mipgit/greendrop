import 'package:flutter/material.dart';

class TreeGardenCard extends StatelessWidget {
  final String name;
  final int price;
  final String imagePath;
  final bool isLocked;

  const TreeGardenCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100.0, 
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                    Text(
                      '${price} coins',
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox( 
              width: 100.0, 
              height: double.infinity,
              child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}