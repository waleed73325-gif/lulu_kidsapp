import 'package:flutter_test/flutter_test.dart';
import 'package:lulu_kids/main.dart';

void main() {
  testWidgets('Lulu Kids app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LuluKidsApp(isTest: true));
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining('لولو'), findsWidgets);
    expect(find.text('Lulu Kids'), findsWidgets);
    expect(find.text('ابدأ الآن'), findsOneWidget);
    expect(find.text('عالم لولو التعليمي'), findsOneWidget);
  });
}
