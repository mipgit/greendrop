// test/view/create_task_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/tasks/create_task_view.dart';

@GenerateMocks([UserProvider])
import 'create_task_view_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
    // Suppose addPersonalizedTask returns Future<void>
    when(mockUserProvider.addPersonalizedTask(any))
      .thenAnswer((_) async {});
  });

  /// Wraps a button that opens your dialog so we can test Navigator.pop
  Widget _buildTestApp() {
    return MaterialApp(
      home: ChangeNotifierProvider<UserProvider>.value(
        value: mockUserProvider,
        child: Builder(builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                child: const Text('Open CreateTask'),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const CreateTaskView(),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  testWidgets('CreateTaskView shows fields and cancel closes dialog',
      (WidgetTester tester) async {
    // 1) Pump the app
    await tester.pumpWidget(_buildTestApp());

    // 2) Tap the “Open CreateTask” button
    await tester.tap(find.text('Open CreateTask'));
    await tester.pumpAndSettle();

    // 3) Now the dialog should be visible
    expect(find.text('Create Task'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Task Description'),
           findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create'),
           findsOneWidget);

    // 4) Tap “Cancel” and ensure dialog is dismissed
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // No AlertDialog (and thus no CreateTaskView) left
    expect(find.byType(AlertDialog), findsNothing);
  });
}
