import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhai_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('Home Dashboard renders elements correctly', (WidgetTester tester) async {
    // Build the HomeScreen directly in a test environment wrapped in a Material parent
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Verify key titles are rendered
    expect(find.text('BHAI SHIELD'), findsOneWidget);
    
    // Verify SOS button instructions are present
    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('HOLD OR TAP TWICE'), findsOneWidget);

    // Verify volunteer configuration switcher exists
    expect(find.text('Volunteer Protection Mode'), findsOneWidget);
  });
}
