import 'package:flutter/material.dart';
import 'package:greendrop/view-model/tree_provider.dart';
import 'package:provider/provider.dart';

class TreeHomeCard extends StatelessWidget {
  TreeHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TreeProvider>(context);
    final tree = prov.tree;
    final curLevelIndex = tree.curLevel;
    final curLevel =
        curLevelIndex < tree.levels.length ? tree.levels[curLevelIndex] : null;

    final currentLevelNumber = curLevelIndex + 1;
    //final totalLevels = tree.levels.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final titleFontSize = screenWidth * 0.09;
    final speciesFontSize = screenWidth * 0.04;
    final progressIndicatorHeight = screenHeight * 0.01;
    final imageWidthSmall = screenWidth * 0.25;
    final imageWidthLarge = screenWidth * 0.60;
    final cardPadding = EdgeInsets.all(screenWidth * 0.02);
    final progressIndicatorPaddingVertical = screenHeight * 0.015;
    final progressIndicatorPaddingHorizontal = screenWidth * 0.05;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.005,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.01),
            Text(
              tree.name,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.001),
            Text(
              tree.species,
              style: TextStyle(fontSize: speciesFontSize, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.023),

            // Progress Indicator
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: progressIndicatorPaddingHorizontal,
                vertical: progressIndicatorPaddingVertical,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 220, 236, 202), //fix!!!
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                    ),
                    child: Text(
                      '$currentLevelNumber',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Container(
                    width: screenWidth * 0.3,
                    height: progressIndicatorHeight * 0.7,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255), //fix!!!
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final dropletsNeeded = prov.getDropletsNeededForNextLevel();
                          final progressFactor = dropletsNeeded > 0
                              ? tree.dropletsUsed / dropletsNeeded
                              : 1.0; // if no next level, consider it full
                          final clampedProgressFactor = progressFactor.clamp(0.0, 1.0);

                          return FractionallySizedBox(
                            widthFactor: clampedProgressFactor,
                            heightFactor: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 186, 218, 153), //fix!!!
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  // maybe add total levels ?
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width:
                        tree.curLevel == 0 ? imageWidthSmall : imageWidthLarge,
                    child:
                        curLevel != null
                            ? Image.asset(
                              curLevel.levelPicture,
                              fit: BoxFit.contain,
                            )
                            : const SizedBox(),
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.001),
            Text('Droplets Used: ${tree.dropletsUsed}', style: TextStyle(color: Colors.blueGrey.shade100)),
            SizedBox(height: screenHeight * 0.005),

          ],
        ),
      ),
    );
  }
}
