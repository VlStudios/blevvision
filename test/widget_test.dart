import 'package:flutter_test/flutter_test.dart';

import 'package:blevvision/main.dart';

void main() {
  testWidgets('renderiza app base', (WidgetTester tester) async {
    await tester.pumpWidget(const BlevVisionApp(startOnboarding: false));

    expect(find.byType(BlevVisionApp), findsOneWidget);
  });
}
