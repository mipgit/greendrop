import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/services/group_service.dart';
import 'package:greendrop/view/groups/join_group_view.dart';

import 'join_group_view_test.mocks.dart';

@GenerateMocks([GroupService])
void main() {
  late MockGroupService mockGroupService;

  setUp(() {
    mockGroupService = MockGroupService();
    when(mockGroupService.joinGroup(any, any)).thenAnswer((_) async => true);
  });

  Widget createJoinGroupView() {
    return ChangeNotifierProvider<GroupService>(
      create: (_) => mockGroupService,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const JoinGroupView(),
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

  group('JoinGroupView Tests', () {
    testWidgets('renders correctly with title, text field, and buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJoinGroupView());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Join Group'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Enter Group ID'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Join'), findsOneWidget);
    });

    testWidgets('tapping Cancel button dismisses the dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJoinGroupView());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Join Group'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Join Group'), findsNothing);
    });

    testWidgets('tapping Join button with non-empty text field calls joinGroup and dismisses dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJoinGroupView());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      const testGroupId = 'testGroupId123';
      await tester.enterText(find.widgetWithText(TextField, 'Enter Group ID'), testGroupId);

      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();

      verify(mockGroupService.joinGroup(any, testGroupId)).called(1);
      expect(find.text('Join Group'), findsNothing);
    });

    testWidgets('tapping Join button with empty text field does not call joinGroup, shows SnackBar, and does not dismiss dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createJoinGroupView());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join'));
      await tester.pump(); // Pump to show the SnackBar

      verifyNever(mockGroupService.joinGroup(any, any));
      expect(find.text('Please enter a group ID.'), findsOneWidget);
      expect(find.text('Join Group'), findsOneWidget); // Dialog should still be present
    });
  });
}