import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart' as app;
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart';
import 'package:mockito/mockito.dart';

class MockUserProvider extends Mock implements UserProvider {
  MockUserProvider();

  app.User mockUser = app.User(id: 'testUser', username: 'Test', email: '', ownedTrees: [], droplets: 100);

  @override
  app.User get user => mockUser;

  void setOwnedTrees(List<Map<String, String>> owned) {
    mockUser = mockUser.copyWith(ownedTrees: owned);
    notifyListeners();
  }
}

void main() {
  group('TreeGardenCard Widget Tests', () {
    late MockUserProvider mockUserProvider;
    late Tree testTree;

    setUp(() {
      mockUserProvider = MockUserProvider();
      testTree = Tree(
        id: '1',
        name: 'Oak',
        species: 'Quercus',
        description: 'A sturdy oak tree.',
        price: 100,
        levels: [],
      );
    });

    Widget createWidgetUnderTest({List<Map<String, String>> ownedTrees = const []}) {
      mockUserProvider.setOwnedTrees(ownedTrees);
      return MaterialApp(
        home: ChangeNotifierProvider<UserProvider>(
          create: (_) => mockUserProvider,
          child: TreeGardenCard(
            name: testTree.species,
            price: testTree.price,
            imagePath: 'assets/oak.png',
            tree: testTree,
            onCardTap: () {},
          ),
        ),
      );
    }

    testWidgets('displays tree name, price, and image', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Quercus'), findsOneWidget);
      expect(find.text('100 droplets'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays "Owned!" when the tree is owned', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(ownedTrees: [
        {'treeId': '1'}
      ]));

      expect(find.text('Owned!'), findsOneWidget);
    });

    testWidgets('does not display "Owned!" when the tree is not owned', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(ownedTrees: [
        {'treeId': '2'}
      ]));

      expect(find.text('Owned!'), findsNothing);
    });

    testWidgets('calls onCardTap when the card is tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>(
            create: (_) => mockUserProvider,
            child: TreeGardenCard(
              name: testTree.species,
              price: testTree.price,
              imagePath: 'assets/oak.png',
              tree: testTree,
              onCardTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(tapped, isTrue);
    });

    testWidgets('displays error icon when image fails to load', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>(
            create: (_) => mockUserProvider,
            child: TreeGardenCard(
              name: testTree.species,
              price: testTree.price,
              imagePath: 'invalid_path.png', 
              tree: testTree,
              onCardTap: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}