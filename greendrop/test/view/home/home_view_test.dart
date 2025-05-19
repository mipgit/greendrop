import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/tree_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/home/home_view.dart';
import 'package:greendrop/view/home/tree_home_card.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([UserProvider, TreeProvider])
import 'home_view_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late MockTreeProvider mockTreeProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockTreeProvider = MockTreeProvider();

    // Stub common methods on mock providers
    when(mockUserProvider.user).thenReturn(User(
      id: 'test_user',
      username: 'testuser',
      ownedTrees: [],
      email: "testuser@test.test",
      droplets: 0,
    ));
    when(mockUserProvider.userTrees).thenReturn([]);
    when(mockUserProvider.treeProviders).thenReturn([]);
    when(mockTreeProvider.curLevel).thenReturn(0);
    when(mockTreeProvider.tree).thenReturn(Tree(
      id: '1',
      name: 'Oak Tree',
      species: 'Oak',
      price: 150,
      description: 'A mighty oak.',
      levels: [
        Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/tree.png'),
        Level(levelNumber: 1, requiredDroplets: 10, levelPicture: 'assettree.png'),
      ],
    ));
    when(mockTreeProvider.dropletsUsed).thenReturn(0);
    when(mockTreeProvider.getDropletsNeededForNextLevel()).thenReturn(0); // Added stub here

    // Default stub for waterTree
    when(mockTreeProvider.waterTree(any)).thenReturn(null);
  });

  // Helper function to pump the HomeView
  Widget createHomeViewWidget({required UserProvider userProvider}) {
    return MaterialApp(
      home: ChangeNotifierProvider<UserProvider>.value(
        value: userProvider,
        child: const HomeView(),
      ),
    );
  }

  group('HomeView', () {
    testWidgets('renders correctly when user has no trees',
        (WidgetTester tester) async {
      when(mockUserProvider.userTrees).thenReturn([]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      // Verify no trees message and buy button are displayed
      expect(find.text("You have no trees yet  :("), findsOneWidget);
      expect(find.text("   Buy your first tree!   "), findsOneWidget);
      expect(find.byType(PageView), findsNothing); // PageView should not be present
    });

    testWidgets(
        'verifies the presence and tappability of the "Buy your first tree!" button',
        (WidgetTester tester) async {
      when(mockUserProvider.userTrees).thenReturn([]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      // Verify the button exists and is tappable.
      final buyButtonText = find.text("   Buy your first tree!   ");
      expect(buyButtonText, findsOneWidget);

      // Find the ElevatedButton ancestor of the Text widget
      final buyButton = find.ancestor(
        of: buyButtonText,
        matching: find.byType(ElevatedButton),
      );
      expect(buyButton, findsOneWidget);

      expect(tester.widget<ElevatedButton>(buyButton).enabled, isTrue);
    });
    testWidgets('renders PageView and TreeHomeCards when user has trees',
        (WidgetTester tester) async {
      final mockTree = Tree(
        id: '1',
        name: 'Oak Tree',
        species: 'Oak',
        price: 150,
        description: 'A mighty oak.',
        levels: [],
      );
      when(mockUserProvider.userTrees).thenReturn([mockTree]);
      when(mockUserProvider.treeProviders).thenReturn([mockTreeProvider]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      // Verify PageView and TreeHomeCard are displayed
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(TreeHomeCard), findsOneWidget);
      expect(find.text("You have no trees yet  :("), findsNothing); // Message should not be present
      expect(find.text("   Buy your first tree!   "), findsNothing); // Button should not be present
    });

    testWidgets('updates _currentPageIndex when PageView page changes',
        (WidgetTester tester) async {
      final mockTree1 = Tree(
          id: '1',
          name: 'Oak',
          species: 'Oak',
          price: 150,
          description: '',
          levels: []);
      final mockTree2 = Tree(
          id: '2',
          name: 'Pine',
          species: 'Pine',
          price: 150,
          description: '',
          levels: []);
      final mockTreeProvider1 = MockTreeProvider();
      final mockTreeProvider2 = MockTreeProvider();

      when(mockTreeProvider1.curLevel).thenReturn(0);
      when(mockTreeProvider1.tree).thenReturn(mockTree1);
      when(mockTreeProvider1.dropletsUsed).thenReturn(0);
      when(mockTreeProvider1.getDropletsNeededForNextLevel()).thenReturn(0);

      when(mockTreeProvider2.curLevel).thenReturn(0);
      when(mockTreeProvider2.tree).thenReturn(mockTree2);
      when(mockTreeProvider2.dropletsUsed).thenReturn(0);
      when(mockTreeProvider2.getDropletsNeededForNextLevel()).thenReturn(0);

      when(mockUserProvider.userTrees).thenReturn([mockTree1, mockTree2]);
      when(mockUserProvider.treeProviders)
          .thenReturn([mockTreeProvider1, mockTreeProvider2]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      // Initially on the first page
      expect(find.descendant(of: find.byType(TreeHomeCard), matching: find.text("Oak")), findsExactly(2));
      expect(find.descendant(of: find.byType(TreeHomeCard), matching: find.text("Pine")), findsNothing);

      // Swipe to the second page
      await tester.drag(find.byType(PageView), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // Should now be on the second page
      expect(find.descendant(of: find.byType(TreeHomeCard), matching: find.text("Oak")), findsNothing);
      expect(find.descendant(of: find.byType(TreeHomeCard), matching: find.text("Pine")), findsExactly(2));
    });

    testWidgets('arrow icons visibility based on current page index',
        (WidgetTester tester) async {
      final mockTree1 = Tree(
          id: '1',
          name: 'Oak',
          species: 'Oak',
          price: 150,
          description: '',
          levels: []);
      final mockTree2 = Tree(
          id: '2',
          name: 'Pine',
          species: 'Pine',
          price: 150,
          description: '',
          levels: []);
      final mockTree3 = Tree(
          id: '3',
          name: 'Palm',
          species: 'Palm',
          price: 150,
          description: '',
          levels: []);

      final mockTreeProvider1 = MockTreeProvider();
      final mockTreeProvider2 = MockTreeProvider();
      final mockTreeProvider3 = MockTreeProvider();

      when(mockTreeProvider1.curLevel).thenReturn(0);
      when(mockTreeProvider1.tree).thenReturn(mockTree1);
      when(mockTreeProvider1.dropletsUsed).thenReturn(0);
      when(mockTreeProvider1.getDropletsNeededForNextLevel()).thenReturn(0); // Added stub here

      when(mockTreeProvider2.curLevel).thenReturn(0);
      when(mockTreeProvider2.tree).thenReturn(mockTree2);
      when(mockTreeProvider2.dropletsUsed).thenReturn(0);
      when(mockTreeProvider2.getDropletsNeededForNextLevel()).thenReturn(0); // Added stub here

      when(mockTreeProvider3.curLevel).thenReturn(0);
      when(mockTreeProvider3.tree).thenReturn(mockTree3);
      when(mockTreeProvider3.dropletsUsed).thenReturn(0);
      when(mockTreeProvider3.getDropletsNeededForNextLevel()).thenReturn(0); // Added stub here


      when(mockUserProvider.userTrees)
          .thenReturn([mockTree1, mockTree2, mockTree3]);
      when(mockUserProvider.treeProviders)
          .thenReturn([mockTreeProvider1, mockTreeProvider2, mockTreeProvider3]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      // On first page: only right arrow visible
      expect(find.byIcon(Icons.arrow_left), findsNothing);
      expect(find.byIcon(Icons.arrow_right), findsOneWidget);

      // Swipe to the second page
      await tester.drag(find.byType(PageView), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // On second page: both arrows visible
      expect(find.byIcon(Icons.arrow_left), findsOneWidget);
      expect(find.byIcon(Icons.arrow_right), findsOneWidget);

      // Swipe to the third page
      await tester.drag(find.byType(PageView), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // On last page: only left arrow visible
      expect(find.byIcon(Icons.arrow_left), findsOneWidget);
      expect(find.byIcon(Icons.arrow_right), findsNothing);
    });

    testWidgets('Water Me! button is enabled when user has droplets',
        (WidgetTester tester) async {
      final mockTree = Tree(
          id: '1',
          name: 'Oak',
          species: 'Oak',
          price: 150,
          description: '',
          levels: []);
      when(mockUserProvider.user).thenReturn(User(
        id: 'test_user',
        username: 'testuser',
        ownedTrees: [], // Corrected type
        email: "testuser@test.test",
        droplets: 10, // User has droplets
      ));
      when(mockUserProvider.userTrees).thenReturn([mockTree]);
      when(mockUserProvider.treeProviders).thenReturn([mockTreeProvider]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      final waterButtonText = find.text("     Water Me!     ");
      expect(waterButtonText, findsOneWidget);

      // Find the ElevatedButton ancestor of the Text widget
      final waterButton = find.ancestor(
        of: waterButtonText,
        matching: find.byType(ElevatedButton),
      );
      expect(waterButton, findsOneWidget);

      expect(tester.widget<ElevatedButton>(waterButton).enabled, isTrue);
    });

    testWidgets(
        'Water Me! button calls waterTree and updates userProvider when user has droplets',
        (WidgetTester tester) async {
      final mockTree = Tree(
          id: '1',
          name: 'Oak',
          species: 'Oak',
          price: 150,
          description: '',
          levels: []);
      final userWithDroplets = User(
        id: 'test_user',
        username: 'testuser',
        ownedTrees: [], // Corrected type
        email: "testuser@test.test",
        droplets: 10, // User has droplets
      );
      when(mockUserProvider.user).thenReturn(userWithDroplets);
      when(mockUserProvider.userTrees).thenReturn([mockTree]);
      when(mockUserProvider.treeProviders).thenReturn([mockTreeProvider]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      final waterButton = find.text("     Water Me!     ");
      await tester.tap(waterButton);
      await tester.pump();

      // Verify that waterTree was called on the mock tree provider
      verify(mockTreeProvider.waterTree(mockUserProvider)).called(1);
    });

    testWidgets(
        'Water Me! button displays SnackBar when user does not have droplets',
        (WidgetTester tester) async {
      final mockTree = Tree(
          id: '1',
          name: 'Oak',
          species: 'Oak',
          price: 150,
          description: '',
          levels: []);
      when(mockUserProvider.user).thenReturn(User(
        id: 'test_user',
        username: 'testuser',
        ownedTrees: [], // Corrected type
        email: "testuser@test.test",
        droplets: 0, // User has no droplets
      ));
      when(mockUserProvider.userTrees).thenReturn([mockTree]);
      when(mockUserProvider.treeProviders).thenReturn([mockTreeProvider]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      final waterButton = find.text("     Water Me!     ");
      await tester.tap(waterButton);
      await tester.pump();

      // Verify that waterTree was NOT called
      verifyNever(mockTreeProvider.waterTree(any));

      // Verify that a SnackBar is displayed
      expect(find.text("You don't have enough droplets."), findsOneWidget);
    });

    testWidgets('applies correct padding to PageView and Water button',
        (WidgetTester tester) async {
      final mockTree = Tree(
          id: '1',
          name: 'Oak',
          species: 'Oak',
          price: 150,
          description: '',
          levels: []);
      when(mockUserProvider.userTrees).thenReturn([mockTree]);
      when(mockUserProvider.treeProviders).thenReturn([mockTreeProvider]);

      await tester.pumpWidget(
          createHomeViewWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle();

      // Verify padding on the PageView's content (TreeHomeCard)
      final treeHomeCard = find.byType(TreeHomeCard);
      expect(
          find.descendant(of: find.byType(Padding), matching: treeHomeCard),
          findsOneWidget);
      // Cannot easily verify exact dynamic padding values without calculating screen size in test

      // Verify padding on the Water button
      final waterButtonPadding = find.descendant(
        of: find.byType(Padding),
        matching: find.text("     Water Me!     "),
      );
      expect(waterButtonPadding, findsOneWidget);
      // Cannot easily verify exact dynamic padding values without calculating screen size in test
    });
  });
}