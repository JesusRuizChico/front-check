import '../models/archivo_imagen.dart';
import '../models/usuario_model.dart';

abstract interface class IPerfilRepository {
  Future<Usuario> actualizarDatos({required String nombre, String? telefono, String? bio});

  Future<void> cambiarContrasena({required String contrasenaActual, required String nuevaContrasena});

  Future<Usuario> actualizarFoto(ArchivoImagen imagen);

  Future<Usuario> eliminarFoto();
}
