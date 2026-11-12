import '../models/registro_usuario.dart';
import '../models/usuario_model.dart';

abstract interface class IAuthRepository {
  Future<Usuario> login(String correo, String contrasena);

  Future<void> registrar(RegistroUsuario registro);

  Future<void> logout();

  /// Devuelve el usuario si la sesión del dispositivo sigue activa.
  Future<Usuario?> sesionActual();

  /// Notifica cuando el servidor rechaza la sesión.
  Stream<void> get sesionExpirada;
}
