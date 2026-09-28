import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_check/main.dart';

void main() {
  testWidgets('la app abre la pantalla de bienvenida', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: ArrendamientoSeguroApp(),
    ));

    expect(find.text('comenzar ahora'), findsOneWidget);
    expect(find.text('ya tengo una cuenta'), findsOneWidget);
  });
}
