import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/task.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/group_provider.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/tasks/tasks_card.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UserProvider, GroupProvider])
import 'tasks_card_test.mocks.dart';

void main() {
  group('TasksCard', () {
    late MockUserProvider mockUserProvider;
    late MockGroupProvider mockGroupProvider;
    late User testUser;
    late VoidCallback mockOnStateChanged;

    setUp(() {
      mockUserProvider = MockUserProvider();
      mockGroupProvider = MockGroupProvider();
      testUser = User(
          id: 'user123',
          username: 'Test User',
          email: 'test@example.com',
          ownedTrees: []); // Simplified user for testing
      mockOnStateChanged = () {}; // Simple mock callback

      when(mockUserProvider.user).thenReturn(testUser);
    });

    testWidgets('renders correctly for different task types and completion states',
        (WidgetTester tester) async {
      // --- Test Case 1: Personalized Task (Not Completed) ---
      final personalizedTaskNotCompleted = Task(
          id: '1',
          description: 'Test Personalized Task',
          dropletReward: 5,
          isCompleted: false,
          isPersonalized: true,
          creationDate: DateTime.now());

      when(mockUserProvider.userTasks).thenReturn([personalizedTaskNotCompleted]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GroupProvider>.value(value: mockGroupProvider),
          ],
          child: MaterialApp(
            home: Scaffold( // Wrap in Scaffold for context
              body: TasksCard(
                  task: personalizedTaskNotCompleted,
                  onStateChanged: mockOnStateChanged,
                  isGroupTask: false),
            ),
          ),
        ),
      );

      expect(find.text('Test Personalized Task'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, const Color.fromARGB(255, 239, 243, 234));

      // --- Test Case 2: Personalized Task (Completed) ---
      final personalizedTaskCompleted = Task(
          id: '1',
          description: 'Test Personalized Task',
          dropletReward: 5,
          isCompleted: true,
          isPersonalized: true,
          creationDate: DateTime.now());

      when(mockUserProvider.userTasks).thenReturn([personalizedTaskCompleted]);


      await tester.pumpWidget(
         MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
             ChangeNotifierProvider<GroupProvider>.value(value: mockGroupProvider),
          ],
          child: MaterialApp(
             home: Scaffold( // Wrap in Scaffold for context
              body: TasksCard(
                  task: personalizedTaskCompleted,
                  onStateChanged: mockOnStateChanged,
                  isGroupTask: false),
            ),
          ),
        ),
      );


      expect(find.text('Test Personalized Task'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
       // Color should be the same for personalized tasks regardless of completion
      final cardWidgetCompleted = tester.widget<Card>(find.byType(Card));
      expect(cardWidgetCompleted.color, const Color.fromARGB(255, 239, 243, 234));


      // --- Test Case 3: Group Task (Not Completed by User) ---
      final groupTaskNotCompleted = Task(
          id: '2',
          description: 'Test Group Task',
          dropletReward: 5,
          isCompleted: false, // isCompleted for the task itself is not used for group task rendering
          isPersonalized: false,
          creationDate: DateTime.now());

       when(mockUserProvider.userTasks).thenReturn([]); // Group tasks are not in userTasks
      when(mockGroupProvider.hasUserCompleted(any)).thenReturn(false);


       await tester.pumpWidget(
         MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GroupProvider>.value(value: mockGroupProvider),
          ],
          child: MaterialApp(
            home: Scaffold( // Wrap in Scaffold for context
              body: TasksCard(
                  task: groupTaskNotCompleted,
                  onStateChanged: mockOnStateChanged,
                  isGroupTask: true),
            ),
          ),
        ),
      );


      expect(find.text('Test Group Task'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(find.text('10'), findsOneWidget); // Reward is doubled for group tasks
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
      final cardWidgetGroup = tester.widget<Card>(find.byType(Card));
      expect(cardWidgetGroup.color, const Color.fromARGB(255, 227, 241, 234));


      // --- Test Case 4: Group Task (Completed by User) ---
      final groupTaskCompleted = Task(
          id: '2',
          description: 'Test Group Task',
          dropletReward: 5,
           isCompleted: false, // isCompleted for the task itself is not used for group task rendering
          isPersonalized: false,
          creationDate: DateTime.now());

       when(mockUserProvider.userTasks).thenReturn([]); // Group tasks are not in userTasks
      when(mockGroupProvider.hasUserCompleted(any)).thenReturn(true);


       await tester.pumpWidget(
         MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GroupProvider>.value(value: mockGroupProvider),
          ],
          child: MaterialApp(
            home: Scaffold( // Wrap in Scaffold for context
              body: TasksCard(
                  task: groupTaskCompleted,
                  onStateChanged: mockOnStateChanged,
                  isGroupTask: true),
            ),
          ),
        ),
      );


      expect(find.text('Test Group Task'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(find.text('10'), findsOneWidget); // Reward is doubled for group tasks
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
      final cardWidgetGroupCompleted = tester.widget<Card>(find.byType(Card));
      expect(cardWidgetGroupCompleted.color, const Color.fromARGB(255, 227, 241, 234));
    });
  });
}