import 'package:flutter_test/flutter_test.dart';

import 'package:makan_bareng/main.dart';

void main() {
  testWidgets('MakanBareng app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MakanBarengApp());
    expect(find.text('MakanBareng'), findsOneWidget);
  });
}
