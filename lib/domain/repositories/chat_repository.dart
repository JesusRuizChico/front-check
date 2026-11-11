import '../models/chat_model.dart';

abstract class IChatRepository {
  Future<List<Conversacion>> getConversaciones(int miUsuarioId);
  Future<Conversacion?> getConversacionPorId(String conversacionId);
  Future<Conversacion> obtenerOIniciarConversacion({
    required int miUsuarioId,
    required int otroUsuarioId,
    required String otroUsuarioNombre,
    String? otroUsuarioFoto,
    String? otroUsuarioRol,
    int? propiedadId,
    String? propiedadTitulo,
  });
  Future<Mensaje> enviarMensaje({
    required String conversacionId,
    required int emisorId,
    required int receptorId,
    required String contenido,
  });
  Stream<List<Conversacion>> get conversacionesStream;
}

