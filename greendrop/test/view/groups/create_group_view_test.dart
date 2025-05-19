import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/view/groups/create_group_view.dart'; // Adjust the import path as needed
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../mock_group_callbacks.dart'; // Import the public helper file


// Generate a mock for the public MockCreateGroupCallbacks class
@GenerateMocks([MockCreateGroupCallbacks])
import 'create_group_view_test.mocks.dart';


void main() {
  late TextEditingController groupNameController;
  late MockMockCreateGroupCallbacks mockCallbacks; // Use the generated mock class name

  setUp(() {
    groupNameController = TextEditingController();
    mockCallbacks = MockMockCreateGroupCallbacks();
  });

  tearDown(() {
    groupNameController.dispose();
  });

  // Helper function to pump the CreateGroupView within a testable environment
  Future<void> pumpCreateGroupView(WidgetTester tester, {
    required TextEditingController controller,
    required Function(BuildContext, String) onCreatePressed,
  }) async {
    await tester.pumpWidget(
      MaterialApp( // MaterialApp is needed for the Navigator
        home: Scaffold( // Scaffold is often needed as a parent for AlertDialog
          body: Builder( // Builder is needed to get a context for showing the AlertDialog
            builder: (BuildContext context) {
              return ElevatedButton( // Use a button to trigger showing the AlertDialog
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CreateGroupView(
                        groupNameController: controller,
                        onCreatePressed: onCreatePressed,
                      );
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

    // Tap the button to show the AlertDialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle(); // Wait for the dialog animation to complete
  }

  group('CreateGroupView', () {
    testWidgets('renders correctly with initial state', (WidgetTester tester) async {
      await pumpCreateGroupView(
        tester,
        controller: groupNameController,
        onCreatePressed: mockCallbacks.onCreate, // Pass the mock method
      );

      // Verify that the AlertDialog is displayed
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verify the title text
      expect(find.text('Create New Group'), findsOneWidget);

      // Verify the TextField for group name
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Group Name'), findsOneWidget); // Verifies the InputDecoration labelText

      // Verify the Cancel button
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Verify the Create button
      expect(find.byType(ElevatedButton).at(1), findsOneWidget); // There are two ElevatedButtons, the second is "Create"
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('tapping Cancel button dismisses the dialog', (WidgetTester tester) async {
      await pumpCreateGroupView(
        tester,
        controller: groupNameController,
        onCreatePressed: mockCallbacks.onCreate, // Pass the mock method
      );

      // Verify that the AlertDialog is displayed initially
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap the Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle(); // Wait for the dialog to dismiss

      // Verify that the AlertDialog is no longer displayed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping Create button calls onCreatePressed with trimmed text', (WidgetTester tester) async {
      await pumpCreateGroupView(
        tester,
        controller: groupNameController,
        onCreatePressed: mockCallbacks.onCreate,
      );

      const testGroupName = '  My Group  ';
      await tester.enterText(find.byType(TextField), testGroupName);

      // Tap the Create button
      await tester.tap(find.text('Create'));

      // Verify that the onCreatePressed callback was called with the trimmed text
      verify(mockCallbacks.onCreate(any, testGroupName.trim())).called(1);
    });

     testWidgets('tapping Create button with empty text calls onCreatePressed with empty string', (WidgetTester tester) async {
       await pumpCreateGroupView(
        tester,
        controller: groupNameController,
        onCreatePressed: mockCallbacks.onCreate,
      );

      // TextField is initially empty
      await tester.tap(find.text('Create'));

      // Verify that the onCreatePressed callback was called with an empty string
      verify(mockCallbacks.onCreate(any, '')).called(1);
     });
  });
}
