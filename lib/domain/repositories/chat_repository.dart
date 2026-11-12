import '../models/chat_model.dart';

abstract interface class IChatRepository {
  Future<List<Conversacion>> obtenerConversaciones();

  Future<List<Mensaje>> obtenerMensajes(int conversacionId);

  Future<MensajeEnviado> enviarMensaje(int conversacionId, String contenido);

  /// Busca si ya existe un chat con el arrendador de la propiedad.
  Future<ContactoPropiedad> contactoDePropiedad(int idPropiedad);

  /// Abre (o reutiliza) el chat con el arrendador enviando el primer mensaje.
  Future<MensajeEnviado> iniciarDesdePropiedad(int idPropiedad, String contenido);

  Future<void> marcarComoLeidos(int conversacionId);
}
