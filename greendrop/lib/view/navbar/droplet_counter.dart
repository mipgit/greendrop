import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';

class DropletCounter extends StatelessWidget {
  const DropletCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isNegative = userProvider.user.droplets < 0;
        final color = isNegative ? const Color.fromARGB(255, 236, 135, 128) : const Color.fromARGB(255, 107, 172, 226);
        final textColor = isNegative ? const Color.fromARGB(255, 165, 19, 8) : const Color.fromARGB(255, 40, 78, 109);

        if (isNegative) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: SizedBox(
                  height: 25,
                  child: Center(
                    child: Text("You are in debt!!! Revert your actions."),
                  ),
                ),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }



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
