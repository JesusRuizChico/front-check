import '../models/usuario_model.dart';

abstract class IAuthRepository {
  Usuario? get usuarioActual;
  Stream<Usuario?> get authStateChanges;

  Future<Usuario> login(String correo, String contrasena);

  Future<Usuario> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
    required String rolSolicitado,
  });

  Future<void> logout();

  void cambiarUsuarioDemo(Usuario usuario);
}

