import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

class DropletCounter extends StatelessWidget {
  const DropletCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isNegative = UserProvider(context).user.droplets < 0;
        final color = isNegative ? const Color.fromARGB(255, 236, 135, 128) : const Color.fromARGB(255, 107, 172, 226);
        final textColor = isNegative ? const Color.fromARGB(255, 99, 25, 20) : const Color.fromARGB(255, 40, 78, 109);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.water_drop_rounded,
              color: color,
            ),
            const SizedBox(width: 2.0),
            Text(
              '${userProvider.user.droplets}',
              style: TextStyle(
                fontSize: 20.0,
                color: textColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
