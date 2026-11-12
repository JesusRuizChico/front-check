import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/dependencias.dart';
import '../../../domain/models/archivo_imagen.dart';
import '../../../domain/repositories/perfil_repository.dart';
import 'sesion_controller.dart';

/// Casos de uso del perfil; cada cambio se refleja en la sesión activa.
class PerfilController {
  final IPerfilRepository _repositorio;
  final SesionController _sesion;

  const PerfilController(this._repositorio, this._sesion);

  Future<void> actualizarDatos({required String nombre, String? telefono, String? bio}) async {
    _sesion.actualizarUsuario(
      await _repositorio.actualizarDatos(nombre: nombre, telefono: telefono, bio: bio),
    );
  }

  Future<void> cambiarContrasena({required String actual, required String nueva}) {
    return _repositorio.cambiarContrasena(contrasenaActual: actual, nuevaContrasena: nueva);
  }

  Future<void> actualizarFoto(ArchivoImagen imagen) async {
    _sesion.actualizarUsuario(await _repositorio.actualizarFoto(imagen));
  }

  Future<void> eliminarFoto() async {
    _sesion.actualizarUsuario(await _repositorio.eliminarFoto());
  }
}

final perfilControllerProvider = Provider(
  (ref) => PerfilController(ref.watch(perfilRepositoryProvider), ref.watch(sesionProvider.notifier)),
);
