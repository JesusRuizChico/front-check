import '../../core/network/api_client.dart';
import '../../domain/models/archivo_imagen.dart';
import '../../domain/models/usuario_model.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../mappers/usuario_mapper.dart';

class ApiPerfilRepository implements IPerfilRepository {
  final ApiClient _api;
  final UsuarioMapper _mapper;

  const ApiPerfilRepository(this._api, this._mapper);

  @override
  Future<Usuario> actualizarDatos({required String nombre, String? telefono, String? bio}) async {
    final json = await _api.put('/perfil', {
      'nombre': nombre,
      'telefono': telefono ?? '',
      'biografia': bio ?? '',
    });
    return _mapper.desdeJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> cambiarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    await _api.put('/perfil/contrasena', {
      'contrasenaActual': contrasenaActual,
      'nuevaContrasena': nuevaContrasena,
    });
  }

  @override
  Future<Usuario> actualizarFoto(ArchivoImagen imagen) async {
    final json = await _api.postMultipart('/perfil/foto', archivos: [
      ArchivoMultipart(campo: 'foto', nombre: imagen.nombre, bytes: imagen.bytes),
    ]);
    return _mapper.desdeJson(json as Map<String, dynamic>);
  }

  @override
  Future<Usuario> eliminarFoto() async {
    final json = await _api.delete('/perfil/foto');
    return _mapper.desdeJson(json as Map<String, dynamic>);
  }
}
