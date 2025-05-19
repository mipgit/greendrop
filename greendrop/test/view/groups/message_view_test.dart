import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/view/groups/message_view.dart';

void main() {
  testWidgets('MessageView renders correctly with basic message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageView(message: 'Hello', isMe: true),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('MessageView renders correctly when isMe is true', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageView(message: 'Hello', isMe: true, timestamp: null),
        ),
      ),
    );

    // Verify alignment
    expect(find.byType(Align), findsOneWidget);
    final alignWidget = tester.widget<Align>(find.byType(Align));
    expect(alignWidget.alignment, Alignment.topRight);

    // Verify background color (checking the container)
    final containerFinder = find.descendant(
      of: find.byType(MessageView),
      matching: find.byType(Container),
    );
    expect(containerFinder, findsOneWidget);
    final containerWidget = tester.widget<Container>(containerFinder);
    final decoration = containerWidget.decoration as BoxDecoration?;
    expect(decoration?.color, Colors.green.shade300);

    // Verify text color
    final textWidget = tester.widget<Text>(find.text('Hello'));
    expect(textWidget.style?.color, Colors.white);

    // Verify timestamp text color (should not be present in this test case as timestamp is null)
    expect(find.byWidgetPredicate((widget) => widget is Text && widget.data != null && widget.data!.contains(':')), findsNothing);
  });

  testWidgets('MessageView renders correctly when isMe is false', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageView(message: 'Hi', isMe: false, timestamp: null),
        ),
      ),
    );

    // Verify alignment
    expect(find.byType(Align), findsOneWidget);
    final alignWidget = tester.widget<Align>(find.byType(Align));
    expect(alignWidget.alignment, Alignment.topLeft);

    // Verify background color (checking the container)
    final containerFinder = find.descendant(
      of: find.byType(MessageView),
      matching: find.byType(Container),
    );
    expect(containerFinder, findsOneWidget);
    final containerWidget = tester.widget<Container>(containerFinder);
    final decoration = containerWidget.decoration as BoxDecoration?;
    expect(decoration?.color, Colors.grey.shade300);

    // Verify text color
    final textWidget = tester.widget<Text>(find.text('Hi'));
    expect(textWidget.style?.color, Colors.black);

    // Verify timestamp text color (should not be present in this test case as timestamp is null)
    expect(find.byWidgetPredicate((widget) => widget is Text && widget.data != null && widget.data!.contains(':')), findsNothing);
  });

  testWidgets('MessageView displays formatted timestamp when timestamp is present', (WidgetTester tester) async {
    final timestamp = Timestamp.fromDate(DateTime(2023, 10, 27, 14, 30)); // 2:30 PM
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageView(message: 'Test', isMe: true, timestamp: timestamp),
        ),
      ),
    );

    expect(find.text('14:30'), findsOneWidget);
  });

  testWidgets('MessageView does not display timestamp when timestamp is null', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageView(message: 'No timestamp', isMe: false, timestamp: null),
        ),
      ),
    );

    // Verify that no Text widget contains a string that looks like a time format (HH:mm)
    expect(find.byWidgetPredicate((widget) => widget is Text && widget.data != null && RegExp(r'^\d{2}:\d{2}$').hasMatch(widget.data!)), findsNothing);

    // Alternatively, and perhaps more directly, check for the absence of the Row that holds the timestamp:
    expect(find.byKey(const ValueKey('timestampRow')), findsNothing); // Assuming you add a key to the Row
  });


  testWidgets('MessageView displays message content correctly', (WidgetTester tester) async {
    const testMessage = 'This is a test message!';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageView(message: testMessage, isMe: true),
        ),
      ),
    );

    expect(find.text(testMessage), findsOneWidget);
  });

  testWidgets('MessageView formats timestamp as HH:mm', (WidgetTester tester) async {
    final timestamp = Timestamp.fromDate(DateTime(2023, 10, 27, 9, 5)); // 9:05 AM
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageView(message: 'Time test', isMe: false, timestamp: timestamp),
        ),
      ),
    );

    expect(find.text('09:05'), findsOneWidget);
  });

  testWidgets('MessageView applies correct padding and decoration', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageView(message: 'Styled', isMe: true, timestamp: null),
        ),
      ),
    );

    final containerFinder = find.descendant(
      of: find.byType(MessageView),
      matching: find.byType(Container),
    );
    expect(containerFinder, findsOneWidget);
    final containerWidget = tester.widget<Container>(containerFinder);

    // Verify padding
    expect(containerWidget.padding, const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0));

    // Verify decoration
    final decoration = containerWidget.decoration as BoxDecoration?;
    expect(decoration, isNotNull);
    expect(decoration?.borderRadius, BorderRadius.circular(12));
  });
}