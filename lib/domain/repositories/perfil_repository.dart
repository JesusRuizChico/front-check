import '../models/usuario_model.dart';

abstract class IPerfilRepository {
  Future<Usuario> getPerfil();
  Future<Usuario> actualizarPerfil({
    required String nombre,
    String? telefono,
    String? bio,
  });
  Future<void> cambiarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  });
  Future<Usuario> actualizarFoto(String fotoUrl);
  Future<Usuario> eliminarFoto();
}

