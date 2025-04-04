import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/home/tree_home_card.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  //FALTA ORGANIZAR ISTO :D

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: userProvider.treeProviders.length,
                  itemBuilder: (context, index) {
                    final treeProvider = userProvider.treeProviders[index]; // Get TreeProvider once
                    return ChangeNotifierProvider.value(
                      value: treeProvider,
                      child: Column(
                        children: [
                          TreeHomeCard(
                            onWater: () {
                              treeProvider.waterTree(); // use the treeProvider that was already retrieved.
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              treeProvider.waterTree(); // use the treeProvider that was already retrieved.
                            },
                            child: const Text("Water Me!"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}