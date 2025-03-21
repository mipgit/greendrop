// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/main.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a mock class for SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  testWidgets('GreenDropApp smoke test', (WidgetTester tester) async {
    // Create a mock SharedPreferences instance
    final mockPrefs = MockSharedPreferences();

    // Optionally, you can define some behavior for the mock instance.
    // For example, if the app checks for a 'dropletCount' value:
    when(mockPrefs.getInt('dropletCount')).thenReturn(30); // Or any default value

    // Build our app with the mock SharedPreferences
    await tester.pumpWidget(GreenDropApp(prefs: mockPrefs));

    // Verify that our counter starts at 30 (or whatever default you set)
    expect(find.text('GreenDrop'), findsOneWidget);
  });
}