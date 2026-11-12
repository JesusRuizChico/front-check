import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/dependencias.dart';
import '../../../domain/models/registro_usuario.dart';
import '../../../domain/models/usuario_model.dart';
import '../../../domain/repositories/auth_repository.dart';

class SesionState {
  final bool inicializada;
  final Usuario? usuario;

  const SesionState({this.inicializada = false, this.usuario});

  bool get autenticado => usuario != null;
}

/// Mantiene al usuario autenticado y coordina inicio y cierre de sesión.
class SesionController extends Notifier<SesionState> {
  IAuthRepository get _repositorio => ref.read(authRepositoryProvider);

  @override
  SesionState build() {
    final suscripcion = ref.watch(authRepositoryProvider).sesionExpirada.listen((_) => _descartar());
    ref.onDispose(suscripcion.cancel);
    Future.microtask(_restaurar);
    return const SesionState();
  }

  Future<Usuario> iniciarSesion(String correo, String contrasena) async {
    final usuario = await _repositorio.login(correo.trim().toLowerCase(), contrasena);
    state = SesionState(inicializada: true, usuario: usuario);
    return usuario;
  }

  /// Crea la cuenta y entra directamente con ella.
  Future<Usuario> registrarse(RegistroUsuario registro) async {
    await _repositorio.registrar(registro);
    return iniciarSesion(registro.correo, registro.contrasena);
  }

  Future<void> cerrarSesion() async {
    await _repositorio.logout();
    _descartar();
  }

  void actualizarUsuario(Usuario usuario) {
    state = SesionState(inicializada: true, usuario: usuario);
  }

  Future<void> _restaurar() async {
    try {
      final usuario = await _repositorio.sesionActual();
      state = SesionState(inicializada: true, usuario: usuario);
    } catch (_) {
      state = const SesionState(inicializada: true);
    }
  }

  void _descartar() {
    state = const SesionState(inicializada: true);
  }
}

final sesionProvider = NotifierProvider<SesionController, SesionState>(SesionController.new);

/// Identificador del usuario actual; los datos dependientes se recargan cuando cambia.
final usuarioActualIdProvider = Provider<int?>((ref) => ref.watch(sesionProvider.select((s) => s.usuario?.id)));
