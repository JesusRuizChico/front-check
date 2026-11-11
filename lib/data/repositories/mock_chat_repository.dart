import '../../domain/models/chat_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../mock_database.dart';

class MockChatRepository implements IChatRepository {
  final MockDatabase _db;

  MockChatRepository([MockDatabase? db]) : _db = db ?? mockDatabase;

  @override
  Stream<List<Conversacion>> get conversacionesStream => _db.conversacionesStream;

  @override
  Future<List<Conversacion>> getConversaciones(int miUsuarioId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.conversaciones;
  }

  @override
  Future<Conversacion?> getConversacionPorId(String conversacionId) async {
    try {
      _db.marcarConversacionLeida(conversacionId);
      return _db.conversaciones.firstWhere((c) => c.id == conversacionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Conversacion> obtenerOIniciarConversacion({
    required int miUsuarioId,
    required int otroUsuarioId,
    required String otroUsuarioNombre,
    String? otroUsuarioFoto,
    String? otroUsuarioRol,
    int? propiedadId,
    String? propiedadTitulo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.obtenerOIniciarConversacion(
      miUsuarioId: miUsuarioId,
      otroUsuarioId: otroUsuarioId,
      otroUsuarioNombre: otroUsuarioNombre,
      otroUsuarioFoto: otroUsuarioFoto,
      otroUsuarioRol: otroUsuarioRol,
      propiedadId: propiedadId,
      propiedadTitulo: propiedadTitulo,
    );
  }

  @override
  Future<Mensaje> enviarMensaje({
    required String conversacionId,
    required int emisorId,
    required int receptorId,
    required String contenido,
  }) async {
    return _db.enviarMensaje(
      conversacionId: conversacionId,
      emisorId: emisorId,
      receptorId: receptorId,
      contenido: contenido,
    );
  }
}

final mockChatRepository = MockChatRepository();

