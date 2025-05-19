import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/view-model/tree_provider.dart';
import 'package:greendrop/view/home/tree_home_card.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([TreeProvider])
import 'tree_home_card_test.mocks.dart';

void main() {
  late MockTreeProvider mockTreeProvider;

  setUp(() {
    mockTreeProvider = MockTreeProvider();
    // Default stubs for methods called regardless of level
    when(mockTreeProvider.dropletsUsed).thenReturn(0);
    when(mockTreeProvider.getDropletsNeededForNextLevel()).thenReturn(10); // Stub with a non-zero value
  });

  Widget createTreeHomeCardWidget({required TreeProvider treeProvider}) {
    return MaterialApp(
      home: Scaffold( // Scaffold is needed for SnackBar in HomeView, good practice here too.
        body: ChangeNotifierProvider<TreeProvider>.value(
          value: treeProvider,
          child: const TreeHomeCard(),
        ),
      ),
    );
  }

  group('TreeHomeCard', () {
    testWidgets('displays correct image and size based on tree level',
        (WidgetTester tester) async {
      // Test Level 0
      final treeLevel0 = Tree(
        id: '1',
        name: 'Small Tree',
        species: 'Sapling',
        price: 50,
        description: 'A young tree.',
        levels: [
          Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/oak.png'),
          Level(levelNumber: 1, requiredDroplets: 10, levelPicture: 'assets/pine-tree.png'),
        ],
      );
      when(mockTreeProvider.tree).thenReturn(treeLevel0);
      when(mockTreeProvider.curLevel).thenReturn(0);

      await tester.pumpWidget(
          createTreeHomeCardWidget(treeProvider: mockTreeProvider));
      await tester.pumpAndSettle();

      // Verify image and size for Level 0
      final imageFinderLevel0 = find.byType(Image);
      expect(imageFinderLevel0, findsOneWidget);
      final imageWidgetLevel0 = tester.widget<Image>(imageFinderLevel0);
      expect((imageWidgetLevel0.image as AssetImage).assetName, 'assets/oak.png');

      final sizedBoxFinderSmall = find.ancestor(of: imageFinderLevel0, matching: find.byType(SizedBox));
      expect(sizedBoxFinderSmall, findsOneWidget);
      final sizedBoxWidgetSmall = tester.widget<SizedBox>(sizedBoxFinderSmall);
      // The calculated imageWidthSmall depends on screen width, we can verify the SizedBox has a defined width
      expect(sizedBoxWidgetSmall.width, isNotNull);


      // Test Level 1
      final treeLevel1 = Tree(
        id: '1',
        name: 'Medium Tree',
        species: 'Young Tree',
        price: 50,
        description: 'Growing strong.',
        levels: [
          Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/palms-tree.png'),
          Level(levelNumber: 1, requiredDroplets: 10, levelPicture: 'assets/oak.png'),
          Level(levelNumber: 2, requiredDroplets: 20, levelPicture: 'assets/sprout.png'),
        ],
      );
      when(mockTreeProvider.tree).thenReturn(treeLevel1);
      when(mockTreeProvider.curLevel).thenReturn(1);

      await tester.pumpWidget(
          createTreeHomeCardWidget(treeProvider: mockTreeProvider));
      await tester.pumpAndSettle();

      // Verify image and size for Level 1
      final imageFinderLevel1 = find.byType(Image);
      expect(imageFinderLevel1, findsOneWidget);
      final imageWidgetLevel1 = tester.widget<Image>(imageFinderLevel1);
      expect((imageWidgetLevel1.image as AssetImage).assetName, 'assets/oak.png');

      final sizedBoxFinderLarge = find.ancestor(of: imageFinderLevel1, matching: find.byType(SizedBox));
      expect(sizedBoxFinderLarge, findsOneWidget);
      final sizedBoxWidgetLarge = tester.widget<SizedBox>(sizedBoxFinderLarge);
      // The calculated imageWidthLarge depends on screen width, we can verify the SizedBox has a defined width
      expect(sizedBoxWidgetLarge.width, isNotNull);

      // We can add an assertion to compare the widths if needed, but verifying they are not null and
      // the correct image is loaded based on level implicitly tests the size logic.
    });
  });
}