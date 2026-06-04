import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makan_bareng/widgets/custom_button.dart';
import 'package:makan_bareng/widgets/avatar_widget.dart';

void main() {
  group('Widget Tests — Reusable Components', () {
    testWidgets('CustomButton renders text and triggers onPressed', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      // Verify the button text is rendered
      expect(find.text('Test Button'), findsOneWidget);

      // Tap on the button and verify it triggers onPressed
      await tester.tap(find.text('Test Button'));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('AvatarWidget displays initials correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              name: 'Deon Aja',
            ),
          ),
        ),
      );

      // 'Deon Aja' -> initials should be 'DA'
      expect(find.text('DA'), findsOneWidget);
    });
  });
}
