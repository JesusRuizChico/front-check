import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/di/dependencias.dart';
import 'package:front_check/domain/models/registro_usuario.dart';
import 'package:front_check/domain/models/usuario_model.dart';
import 'package:front_check/domain/repositories/auth_repository.dart';
import 'package:front_check/features/auth/presentation/widgets/boton_cerrar_sesion.dart';

class _AuthConSesion implements IAuthRepository {
  int cierres = 0;

  @override
  Stream<void> get sesionExpirada => const Stream.empty();

  @override
  Future<Usuario?> sesionActual() async =>
      const Usuario(id: 1, nombre: 'Ana', correo: 'ana@example.com', roles: ['arrendatario']);

  @override
  Future<void> logout() async => cierres++;

  @override
  Future<Usuario> login(String correo, String contrasena) => throw UnimplementedError();

  @override
  Future<void> registrar(RegistroUsuario registro) => throw UnimplementedError();
}

void main() {
  testWidgets('El botón visible pide confirmación y solo cierra sesión al aceptar', (tester) async {
    final auth = _AuthConSesion();
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
      child: MaterialApp(
        home: Scaffold(appBar: AppBar(actions: const [BotonCerrarSesion()])),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cerrar Sesión'));
    await tester.pumpAndSettle();
    expect(find.text('¿Estás seguro de que deseas salir de tu cuenta?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(auth.cierres, 0);

    await tester.tap(find.byTooltip('Cerrar Sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cerrar Sesión'));
    await tester.pumpAndSettle();
    expect(auth.cierres, 1);
  });
}
