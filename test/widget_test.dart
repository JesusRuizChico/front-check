import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/di/dependencias.dart';
import 'package:front_check/domain/models/registro_usuario.dart';
import 'package:front_check/domain/models/usuario_model.dart';
import 'package:front_check/domain/repositories/auth_repository.dart';
import 'package:front_check/main.dart';

/// Repositorio sin sesión activa para probar la pantalla inicial sin red.
class _AuthSinSesion implements IAuthRepository {
  @override
  Stream<void> get sesionExpirada => const Stream.empty();

  @override
  Future<Usuario?> sesionActual() async => null;

  @override
  Future<Usuario> login(String correo, String contrasena) => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> registrar(RegistroUsuario registro) => throw UnimplementedError();
}

void main() {
  testWidgets('Sin sesión se muestra la bienvenida solo con iniciar sesión y crear cuenta',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(_AuthSinSesion())],
      child: const ArrendamientoSeguroApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('HabitaCheck'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Crear una cuenta nueva'), findsOneWidget);
    expect(find.textContaining('Demo'), findsNothing);
  });
}
