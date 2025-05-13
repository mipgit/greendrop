import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

class DropletCounter extends StatelessWidget {
  const DropletCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.water_drop_rounded,
          color: Color.fromARGB(255, 107, 172, 226),
        ),
        const SizedBox(width: 2.0),
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Text(
              '${userProvider.user.droplets}',
              style: const TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 40, 78, 109),
              ),
            );
          },
        ),
      ],
    );
  }
}
