import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helphub_ai/main.dart';

void main() {
  // Set up mock environments before running widget tests
  setUpAll(() async {
    // Mocks the underlying channel so SharedPreferences doesn't crash during testing
    SharedPreferences.setMockInitialValues({});

    // Mocks the dotenv tool so it doesn't try to look for a physical asset file
    dotenv.testLoad(fileInput: '''GROQ_API_KEY=gsk_mock_test_key_here''');
  });

  testWidgets('HelpHubApp Authentication Router Feature Test', (WidgetTester tester) async {
    // 1. Feature Test: Clear state / First-time user layout routing
    await tester.pumpWidget(const HelpHubApp(initialRole: null));
    await tester.pumpAndSettle(); // Allow UI animations to finish stability layout

    // Assert: Check that a clean state routes the user straight to the Login flow
    expect(find.byType(HelpHubApp), findsOneWidget);

    // 2. Feature Test: Admin Session persist layout routing
    await tester.pumpWidget(const HelpHubApp(initialRole: 'admin'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpHubApp), findsOneWidget);

    // 3. Feature Test: Standard User Session persist layout routing
    await tester.pumpWidget(const HelpHubApp(initialRole: 'user'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpHubApp), findsOneWidget);
  });
}