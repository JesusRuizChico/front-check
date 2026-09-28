import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/features/messages/presentation/widgets/chat_avatar.dart';

void main() {
  testWidgets('muestra las iniciales cuando el usuario no tiene foto',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatAvatar(name: 'Arrendador de prueba'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('A'), findsOneWidget);
  });
}
