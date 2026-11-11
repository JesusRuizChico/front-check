import '../../domain/models/usuario_model.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../mock_database.dart';

class MockPerfilRepository implements IPerfilRepository {
  final MockDatabase _db;

  MockPerfilRepository([MockDatabase? db]) : _db = db ?? mockDatabase;

  @override
  Future<Usuario> getPerfil() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final u = _db.usuarioActual;
    if (u == null) throw Exception('No hay usuario autenticado');
    return u;
  }

  @override
  Future<Usuario> actualizarPerfil({
    required String nombre,
    String? telefono,
    String? bio,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _db.actualizarPerfil(
      nombre: nombre,
      telefono: telefono,
      bio: bio,
    );
  }

  @override
  Future<void> cambiarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (contrasenaActual.length < 4) {
      throw Exception('La contraseña actual no es correcta');
    }
  }

  @override
  Future<Usuario> actualizarFoto(String fotoUrl) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _db.actualizarPerfil(
      nombre: _db.usuarioActual?.nombre ?? 'Usuario',
      fotoUrl: fotoUrl,
    );
  }

  @override
  Future<Usuario> eliminarFoto() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.actualizarPerfil(
      nombre: _db.usuarioActual?.nombre ?? 'Usuario',
      fotoUrl: null,
    );
  }
}

final mockPerfilRepository = MockPerfilRepository();

