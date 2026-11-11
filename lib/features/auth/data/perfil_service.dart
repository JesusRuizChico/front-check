import 'package:image_picker/image_picker.dart';
import 'package:front_check/domain/repositories/perfil_repository.dart';
import 'package:front_check/data/repositories/mock_perfil_repository.dart';
import 'package:front_check/domain/repositories/auth_repository.dart';
import 'package:front_check/data/repositories/mock_auth_repository.dart';

class PerfilService {
  final IPerfilRepository _perfilRepository;
  final IAuthRepository _authRepository;

  PerfilService({
    IPerfilRepository? perfilRepository,
    IAuthRepository? authRepository,
  })  : _perfilRepository = perfilRepository ?? mockPerfilRepository,
        _authRepository = authRepository ?? mockAuthRepository;

  Future<Map<String, dynamic>> obtenerPerfil() async {
    final usuario = await _perfilRepository.getPerfil();
    return usuario.toJson();
  }

  Future<Map<String, dynamic>> actualizarPerfil({
    required String nombre,
    String? telefono,
    String? contrasenaActual,
    String? nuevaContrasena,
    String? bio,
  }) async {
    final usuario = await _perfilRepository.actualizarPerfil(
      nombre: nombre,
      telefono: telefono,
      bio: bio,
    );

    if (contrasenaActual != null &&
        contrasenaActual.isNotEmpty &&
        nuevaContrasena != null &&
        nuevaContrasena.isNotEmpty) {
      await _perfilRepository.cambiarContrasena(
        contrasenaActual: contrasenaActual,
        nuevaContrasena: nuevaContrasena,
      );
    }

    return usuario.toJson();
  }

  Future<Map<String, dynamic>> actualizarFoto(XFile imagen) async {
    final usuario = await _perfilRepository.actualizarFoto(
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    );
    return usuario.toJson();
  }

  Future<void> eliminarFoto() async {
    await _perfilRepository.eliminarFoto();
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}

final perfilService = PerfilService();
