import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/home/tree_home_card.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: userProvider.treeProviders.length,
              itemBuilder: (context, index) {
                final treeProvider = userProvider.treeProviders[index];
                return ChangeNotifierProvider.value(
                  value: treeProvider,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TreeHomeCard(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0, top: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade200,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 25.0,
                ),
              ),
              onPressed: () {
                if (userProvider.treeProviders.isNotEmpty &&
                    _currentPageIndex < userProvider.treeProviders.length) {
                  final treeProvider =
                      userProvider.treeProviders[_currentPageIndex];
                  if (userProvider.user.droplets > 0) {
                    treeProvider.waterTree(userProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You don't have enough droplets."),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color.fromARGB(255, 9, 60, 128),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Water Me!",
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
