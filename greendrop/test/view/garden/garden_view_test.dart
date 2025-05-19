import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/garden/garden_view.dart';
import 'package:greendrop/view/garden/tree_garden_card.dart'; 
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Generate mocks
@GenerateMocks([GardenProvider, UserProvider])
import 'garden_view_test.mocks.dart';

void main() {
  late MockGardenProvider mockGardenProvider;
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockGardenProvider = MockGardenProvider();
    mockUserProvider = MockUserProvider();

    // Default behavior for GardenProvider: not loading, no error, empty trees
    when(mockGardenProvider.isLoading).thenReturn(false);
    when(mockGardenProvider.error).thenReturn(null);
    when(mockGardenProvider.allAvailableTrees).thenReturn([]);

    // Default behavior for UserProvider: return a mock User
    when(mockUserProvider.user).thenReturn(User(
      id: 'test_user',
      username: 'testuser',
      ownedTrees: [],
      email: "testuser@test.test",
      droplets: 0,
    ));
  });

  Widget createWidgetUnderTest({
    required MockGardenProvider gardenProvider,
    required MockUserProvider userProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GardenProvider>.value(value: gardenProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: GardenView(),
        ),
      ),
    );
  }

  testWidgets('renders without errors when trees are available and user has no owned trees/inventory/droplets', (WidgetTester tester) async {
    // Mock GardenProvider to return a list of trees
    final mockTrees = [
      Tree(id: '1', name: "ostrich", species: 'Oak', price: 100, description: 'Strong tree', levels: []),
      Tree(id: '2', name: "pickel", species: 'Pine', price: 50, description: 'Green tree', levels: []),
    ];
    when(mockGardenProvider.allAvailableTrees).thenReturn(mockTrees);

    // Mock UserProvider with empty ownedTrees, inventory, and 0 droplets
    when(mockUserProvider.user).thenReturn(User(
      id: 'test_user',
      username: 'testuser',
      ownedTrees: [],
      email: "testuser@test.test",
      droplets: 0,
    ));

    await tester.pumpWidget(createWidgetUnderTest(
      gardenProvider: mockGardenProvider,
      userProvider: mockUserProvider,
    ));

    // Verify that no errors are thrown during rendering
    expect(tester.takeException(), isNull);

    // Verify that the loading indicator is not shown
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Verify that the error message is not shown
    expect(find.textContaining('Error loading trees:'), findsNothing);

    // Verify that the GardenView widget is rendered
    expect(find.byType(GardenView), findsOneWidget);

    // Verify that the sorting dropdown is visible
    expect(find.byType(DropdownButton<GardenSortOption>), findsOneWidget);

    // Verify that the trees are rendered (at least the list view)
    expect(find.byType(ListView), findsOneWidget);

    // Optionally, verify the presence of tree cards based on the mock data
    expect(find.byType(TreeGardenCard), findsNWidgets(mockTrees.length));
    expect(find.text('Oak'), findsOneWidget);
    expect(find.text('Pine'), findsOneWidget);
  });
}