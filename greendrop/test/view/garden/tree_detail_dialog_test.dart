import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/garden/tree_detail_dialog.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Generate mocks
@GenerateMocks([UserProvider])
import 'tree_detail_dialog_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();

    // Default behavior for UserProvider
    when(mockUserProvider.user).thenReturn(User(
      id: 'test_user',
      username: 'testuser',
      ownedTrees: [],
      email: "testuser@test.test",
      droplets: 0,
    ));
    when(mockUserProvider.buyTree(any, any)).thenAnswer((_) async => Future.value()); // Default successful buy
  });

  Widget createWidgetUnderTest({
    required Tree tree,
    required String imagePath,
    required MockUserProvider userProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              // Use a Builder to get a context below the MaterialApp
              return TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return TreeDetailDialog(tree: tree, imagePath: imagePath);
                    },
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      ),
    );
  }

  group('TreeDetailDialog', () {
      testWidgets('renders correctly with tree details', (WidgetTester tester) async {
        final mockTree = Tree(
          id: '1',
          name: 'Oak Tree',
          species: 'Oak',
          price: 150,
          description: 'A mighty oak.',
          levels: [], // Using empty levels to trigger default image
        );
        const mockImagePath = 'assets/tree.png'; // Use a path that will trigger the mock

        await tester.pumpWidget(createWidgetUnderTest(
          tree: mockTree,
          imagePath: mockImagePath,
          userProvider: mockUserProvider,
        ));

        // Tap the button to show the dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle(); // Wait for the dialog to appear

        // Verify dialog title and content
        expect(find.text(mockTree.name), findsOneWidget);
        expect(find.text(mockTree.description), findsOneWidget);
        expect(find.text('150'), findsOneWidget); // Check formatted price

        expect(find.byType(Image), findsOneWidget);

        // Verify the Buy Tree button is present and disabled (default droplets is 0, price is 150)
        final buyButton = find.widgetWithText(ElevatedButton, 'Buy Tree');
        expect(buyButton, findsOneWidget);
        expect(tester.widget<ElevatedButton>(buyButton).onPressed, isNull);
      });

      testWidgets('displays "Owned" when user owns the tree', (WidgetTester tester) async {
        final mockTree = Tree(
          id: '1',
          name: 'Oak Tree',
          species: 'Oak',
          price: 150,
          description: 'A mighty oak.',
          levels: [],
        );
        const mockImagePath = 'assets/oak.png';

        // Mock UserProvider to indicate the user owns the tree
        when(mockUserProvider.user).thenReturn(User(
          id: 'test_user',
          username: 'testuser',
          ownedTrees: [{'treeId': '1', 'purchaseDate': '...'}], // User owns the tree
          email: "testuser@test.test",
          droplets: 1000, // Enough droplets, but ownership is the key
        ));

        await tester.pumpWidget(createWidgetUnderTest(
          tree: mockTree,
          imagePath: mockImagePath,
          userProvider: mockUserProvider,
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify button text is "Owned" and the button is disabled
        final ownedButton = find.widgetWithText(ElevatedButton, 'Owned');
        expect(ownedButton, findsOneWidget);
        expect(tester.widget<ElevatedButton>(ownedButton).onPressed, isNull);
      });

      testWidgets('displays "Buy Tree" and button is enabled when user has enough droplets and does not own the tree', (WidgetTester tester) async {
        final mockTree = Tree(
          id: '1',
          name: 'Oak Tree',
          species: 'Oak',
          price: 150,
          description: 'A mighty oak.',
          levels: [],
        );
        const mockImagePath = 'assets/oak.png';

        // Mock UserProvider to indicate user has enough droplets and doesn't own the tree
        when(mockUserProvider.user).thenReturn(User(
          id: 'test_user',
          username: 'testuser',
          ownedTrees: [], // User does not own the tree
          email: "testuser@test.test",
          droplets: 200, // Enough droplets
        ));

        await tester.pumpWidget(createWidgetUnderTest(
          tree: mockTree,
          imagePath: mockImagePath,
          userProvider: mockUserProvider,
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify button text is "Buy Tree" and the button is enabled
        final buyButton = find.widgetWithText(ElevatedButton, 'Buy Tree');
        expect(buyButton, findsOneWidget);
        expect(tester.widget<ElevatedButton>(buyButton).onPressed, isNotNull);
      });

      testWidgets('calls buyTree, shows success SnackBar, and dismisses dialog on successful purchase', (WidgetTester tester) async {
        final mockTree = Tree(
          id: '1',
          name: 'Oak Tree',
          species: 'Oak',
          price: 150,
          description: 'A mighty oak.',
          levels: [],
        );
        const mockImagePath = 'assets/oak.png';

        // Mock UserProvider with enough droplets and buyTree succeeding
        when(mockUserProvider.user).thenReturn(User(
          id: 'test_user',
          username: 'testuser',
          ownedTrees: [],
          email: "testuser@test.test",
          droplets: 200,
        ));
        // Explicitly mock buyTree to complete successfully
        when(mockUserProvider.buyTree(any, any)).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(createWidgetUnderTest(
          tree: mockTree,
          imagePath: mockImagePath,
          userProvider: mockUserProvider,
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Tap the Buy Tree button
        await tester.tap(find.widgetWithText(ElevatedButton, 'Buy Tree'));
        await tester.pumpAndSettle(); // Wait for async operations, SnackBar, and dialog dismissal

        // Verify buyTree was called with the correct tree ID
        verify(mockUserProvider.buyTree(any, mockTree.id)).called(1);

        // Verify success SnackBar is shown
        expect(find.text('${mockTree.name} purchased!'), findsOneWidget);

        // Verify the dialog is dismissed
        expect(find.byType(AlertDialog), findsNothing);
      });

      testWidgets('calls buyTree, shows error SnackBar, and does NOT dismiss dialog on failed purchase', (WidgetTester tester) async {
        final mockTree = Tree(
          id: '1',
          name: 'Oak Tree',
          species: 'Oak',
          price: 150,
          description: 'A mighty oak.',
          levels: [],
        );
        const mockImagePath = 'assets/oak.png';

        // Mock UserProvider with enough droplets but buyTree throwing an exception
        when(mockUserProvider.user).thenReturn(User(
          id: 'test_user',
          username: 'testuser',
          ownedTrees: [],
          email: "testuser@test.test",
          droplets: 200,
        ));
        // Mock buyTree to throw an exception
        when(mockUserProvider.buyTree(any, any)).thenThrow(Exception('Not enough droplets!'));

        await tester.pumpWidget(createWidgetUnderTest(
          tree: mockTree,
          imagePath: mockImagePath,
          userProvider: mockUserProvider,
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Tap the Buy Tree button
        await tester.tap(find.widgetWithText(ElevatedButton, 'Buy Tree'));
        await tester.pumpAndSettle(); // Wait for async operations, SnackBar, and dialog dismissal

        // Verify buyTree was called
        verify(mockUserProvider.buyTree(any, mockTree.id)).called(1);

        // Verify error SnackBar is shown
        expect(find.textContaining('Error purchasing:'), findsOneWidget);

        // Verify the dialog is NOT dismissed
        expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}