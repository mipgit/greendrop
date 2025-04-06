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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final pagePadding = screenWidth * 0.05; 
    final buttonVerticalPadding = screenHeight * 0.018; 
    final buttonHorizontalPadding = screenWidth * 0.06; 
    final buttonFontSize = screenWidth * 0.045;
    final bottomButtonPaddingBottom = screenHeight * 0.03; 
    final bottomButtonPaddingTop = screenHeight * 0.01; 

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
                    padding: EdgeInsets.all(pagePadding),
                    child: TreeHomeCard(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: bottomButtonPaddingBottom, top: bottomButtonPaddingTop),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 146, 169, 187),
                padding:  EdgeInsets.symmetric(
                  vertical: buttonVerticalPadding,
                  horizontal: buttonHorizontalPadding,
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
                      ),
                    );
                  }
                }
              },
              child: Text(
                "     Water Me!     ",
                style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
