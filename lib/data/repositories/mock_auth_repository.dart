import 'dart:async';
import '../../domain/models/usuario_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mock_database.dart';

class MockAuthRepository implements IAuthRepository {
  final MockDatabase _db;
  final _authStateController = StreamController<Usuario?>.broadcast();

  MockAuthRepository([MockDatabase? db]) : _db = db ?? mockDatabase {
    _authStateController.add(_db.usuarioActual);
    _db.addListener(() {
      _authStateController.add(_db.usuarioActual);
    });
  }

  @override
  Usuario? get usuarioActual => _db.usuarioActual;

  @override
  Stream<Usuario?> get authStateChanges => _authStateController.stream;

  @override
  Future<Usuario> login(String correo, String contrasena) async {
    // Simula latencia de red realista de 300ms
    await Future.delayed(const Duration(milliseconds: 300));
    final usuario = _db.login(correo, contrasena);
    return usuario;
  }

  @override
  Future<Usuario> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
    required String rolSolicitado,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final usuario = _db.registrarUsuario(
      nombre: nombre,
      correo: correo,
      contrasena: contrasena,
      telefono: telefono,
      rolSolicitado: rolSolicitado,
    );
    return usuario;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _db.logout();
  }

  @override
  void cambiarUsuarioDemo(Usuario usuario) {
    _db.setUsuarioActual(usuario);
  }
}

final mockAuthRepository = MockAuthRepository();

