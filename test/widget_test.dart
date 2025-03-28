import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echoseal/main.dart';

void main() {
  testWidgets('Home screen loads and navigates correctly', (WidgetTester tester) async {
    // Load the main app
    await tester.pumpWidget(MyApp());

    // Verify the home screen is displayed
    expect(find.text('Echoseal'), findsOneWidget);

    // Check if FloatingActionButton exists
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap the FloatingActionButton (Chatbot button)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // Verify that the Chatbot screen is now displayed
    expect(find.text('Chatbot'), findsOneWidget);
  });
}
