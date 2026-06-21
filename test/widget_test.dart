import 'package:flutter_test/flutter_test.dart';
import 'package:habit_os/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitOsApp());
    expect(find.text('Habit_OS'), findsOneWidget);
  });
}
