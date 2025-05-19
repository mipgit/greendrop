import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:greendrop/view/tasks/tasks_view.dart';

@GenerateMocks([UserProvider])
import 'tasks_view_test.mocks.dart';

void main() {
  group('TasksView', () {
    testWidgets('renders empty state correctly when no tasks are available',
        (WidgetTester tester) async {
      late MockUserProvider mockUserProvider;

      mockUserProvider = MockUserProvider();

      // Stub userTasks to return an empty list
      when(mockUserProvider.userTasks).thenReturn([]);

      // Stub countdownNotifier
      final countdownNotifier = ValueNotifier(Duration(hours: 1, minutes: 30, seconds: 0));
      when(mockUserProvider.countdownNotifier).thenReturn(countdownNotifier);

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: const MaterialApp(
            home: TasksView(),
          ),
        ),
      );

      // Verify that the empty state message is displayed
      expect(find.text('No tasks available at the moment.'), findsOneWidget);

      // Verify that the ReorderableListView is not present
      expect(find.byType(ReorderableListView), findsNothing);
    });
  });
}