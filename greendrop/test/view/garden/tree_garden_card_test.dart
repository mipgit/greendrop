import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Generate mocks
@GenerateMocks([UserProvider])
import 'tree_garden_card_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  
  String testAssetPath = 'assets/tree.png';

  setUp(() {
    mockUserProvider = MockUserProvider();

    // Default behavior for UserProvider: user does not own the tree
    when(mockUserProvider.user).thenReturn(User(
      id: 'test_user',
      username: 'testuser',
      ownedTrees: [],
      email: "testuser@test.test",
      droplets: 0,
    ));
  });

  Widget createWidgetUnderTest({
    required Tree tree,
    required String imagePath,
    required VoidCallback onCardTap,
    required MockUserProvider userProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TreeGardenCard(
            name: tree.name,
            price: tree.price,
            imagePath: imagePath,
            tree: tree,
            onCardTap: onCardTap,
          ),
        ),
      ),
    );
  }

  group('TreeGardenCard', () {
    final mockTree = Tree(
      id: '1',
      name: 'Test Tree',
      species: 'test_tree',
      price: 100,
      description: 'A test tree.',
      levels: [],
    );

    testWidgets('renders correctly with tree details when not owned', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        tree: mockTree,
        imagePath: testAssetPath, // Use the test asset path
        onCardTap: () {},
        userProvider: mockUserProvider,
      ));

      // Verify text is displayed
      expect(find.text(mockTree.name), findsOneWidget);
       // Verify price text is displayed
      expect(find.text('100'), findsOneWidget);


      // Verify image is displayed
      expect(find.byType(Image), findsOneWidget);

      // Verify icon is "add" and color is black
      expect(find.byIcon(Icons.add), findsOneWidget);
      final addIcon = tester.widget<Icon>(find.byIcon(Icons.add));
      expect(addIcon.color, Colors.black);

      // Verify card elevation and color when not owned
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2.0);
      expect(card.color, const Color.fromARGB(204, 226, 221, 221));
    });

    testWidgets('renders correctly with tree details when owned', (WidgetTester tester) async {
      // Mock UserProvider to indicate the user owns the tree
      when(mockUserProvider.user).thenReturn(User(
        id: 'test_user',
        username: 'testuser',
        ownedTrees: [{'treeId': '1', 'purchaseDate': '...'}], // User owns the tree
        email: "testuser@test.test",
        droplets: 0,
      ));

      await tester.pumpWidget(createWidgetUnderTest(
        tree: mockTree,
        imagePath: testAssetPath, // Use the test asset path
        onCardTap: () {},
        userProvider: mockUserProvider,
      ));

      // Verify text is displayed
      expect(find.text(mockTree.name), findsOneWidget);
       // Verify price text is displayed
      expect(find.text('100'), findsOneWidget);

      // Verify image is displayed
      expect(find.byType(Image), findsOneWidget);

      // Verify icon is "check" and color is green
      expect(find.byIcon(Icons.check), findsOneWidget);
      final checkIcon = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(checkIcon.color, Colors.green);

      // Verify card elevation and color when owned
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 1.0);
      // When owned, the color is null, which defaults to the theme's card color.
      // Checking for null is sufficient here.
      expect(card.color, isNull);
    });

    testWidgets('calls onCardTap when the card is tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        tree: mockTree,
        imagePath: testAssetPath, // Use the test asset path
        onCardTap: () {
          tapped = true;
        },
        userProvider: mockUserProvider,
      ));

      // Tap the card
      await tester.tap(find.byType(Card));
      await tester.pump(); // Pump to process the tap gesture

      // Verify that the onCardTap callback was called
      expect(tapped, isTrue);
    });

    // You can add more tests here for edge cases or specific styling if needed.
  });
}
