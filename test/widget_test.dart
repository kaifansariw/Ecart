import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton renders label correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            label: 'Test Button',
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(find.text('Test Button'), findsOneWidget);
  });
}
