import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_check/main.dart';

void main() {
  testWidgets('HabitaCheck app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArrendamientoSeguroApp()));
    await tester.pumpAndSettle();

    expect(find.text('HabitaCheck'), findsOneWidget);
  });
}
