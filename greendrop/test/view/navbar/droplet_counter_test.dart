import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/navbar/droplet_counter.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UserProvider])
import 'droplet_counter_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
  });

  Widget createDropletCounterWidget({required UserProvider userProvider}) {
    return MaterialApp(
      home: Scaffold( // Add Scaffold as SnackBar needs it
        body: ChangeNotifierProvider<UserProvider>.value(
          value: userProvider,
          child: const DropletCounter(),
        ),
      ),
    );
  }

  group('DropletCounter', () {
    testWidgets('displays droplet count and changes color based on value',
        (WidgetTester tester) async {
      // Test with positive droplets
      when(mockUserProvider.user).thenReturn(User(
        id: 'test_user',
        username: 'testuser',
        ownedTrees: [],
        email: "testuser@test.test",
        droplets: 10,
      ));

      await tester.pumpWidget(
          createDropletCounterWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle(); // Pump to allow animations/async to settle

      // Verify text and colors for positive droplets
      expect(find.text('10'), findsOneWidget);
      final positiveIcon = tester.widget<Icon>(find.byIcon(Icons.water_drop_rounded));
      expect(positiveIcon.color, const Color.fromARGB(255, 107, 172, 226));
      final positiveText = tester.widget<Text>(find.text('10'));
      expect(positiveText.style?.color, const Color.fromARGB(255, 40, 78, 109));

      // Test with negative droplets
      // It's often better to create a new provider or clear stubs for distinct test states
      mockUserProvider = MockUserProvider(); // Create a new mock provider
      when(mockUserProvider.user).thenReturn(User(
        id: 'test_user',
        username: 'testuser',
        ownedTrees: [],
        email: "testuser@test.test",
        droplets: -5,
      ));

      await tester.pumpWidget(
          createDropletCounterWidget(userProvider: mockUserProvider));
      await tester.pumpAndSettle(); // Pump again for the new state

      // Verify text and colors for negative droplets
      expect(find.text('-5'), findsOneWidget);
      final negativeIcon = tester.widget<Icon>(find.byIcon(Icons.water_drop_rounded));
      expect(negativeIcon.color, const Color.fromARGB(255, 236, 135, 128));
      final negativeText = tester.widget<Text>(find.text('-5'));
      expect(negativeText.style?.color, const Color.fromARGB(255, 165, 19, 8));
    });
  });
}