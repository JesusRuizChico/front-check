import 'package:front_check/domain/models/usuario_model.dart';
import 'package:front_check/domain/repositories/auth_repository.dart';
import 'package:front_check/data/repositories/mock_auth_repository.dart';

class AuthService {
  final IAuthRepository _repository;

  AuthService([IAuthRepository? repository])
      : _repository = repository ?? mockAuthRepository;

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final usuario = await _repository.login(correo, contrasena);
    return {
      'id': usuario.id,
      'nombre': usuario.nombre,
      'correo': usuario.correo,
      'rolesActivos': usuario.roles,
    };
  }

  Future<Map<String, dynamic>> register(
    String nombre,
    String correo,
    String contrasena,
    String telefono,
    String rolSolicitado,
  ) async {
    final usuario = await _repository.register(
      nombre: nombre,
      correo: correo,
      contrasena: contrasena,
      telefono: telefono,
      rolSolicitado: rolSolicitado,
    );
    return {
      'id': usuario.id,
      'nombre': usuario.nombre,
      'correo': usuario.correo,
      'rolesActivos': usuario.roles,
    };
  }

  Usuario? get usuarioActual => _repository.usuarioActual;
  Future<void> logout() => _repository.logout();
}

final authService = AuthService();
