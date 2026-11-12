import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../domain/models/registro_usuario.dart';
import '../../domain/models/usuario_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/usuario_mapper.dart';

class ApiAuthRepository implements IAuthRepository {
  final ApiClient _api;
  final UsuarioMapper _mapper;

  const ApiAuthRepository(this._api, this._mapper);

  @override
  Stream<void> get sesionExpirada => _api.sesionExpirada;

  @override
  Future<Usuario> login(String correo, String contrasena) async {
    final json = await _api.post('/auth/login', {'correo': correo, 'contrasena': contrasena});
    return _mapper.desdeJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> registrar(RegistroUsuario registro) async {
    await _api.post('/auth/registro', {
      'nombre': registro.nombre,
      'correo': registro.correo,
      'contrasena': registro.contrasena,
      'telefono': registro.telefono,
      'rolSolicitado': registro.rol,
    });
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } on ApiException {
      // Aunque el servidor no responda, la sesión local se descarta.
    } finally {
      _api.reiniciar();
    }
  }

  @override
  Future<Usuario?> sesionActual() async {
    try {
      final json = await _api.get('/perfil');
      return _mapper.desdeJson(json as Map<String, dynamic>);
    } on ApiException catch (error) {
      if (error.esNoAutorizado) return null;
      rethrow;
    }
  }
}
