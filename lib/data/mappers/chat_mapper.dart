import '../../core/network/media_url_resolver.dart';
import '../../domain/models/chat_model.dart';
import 'json_lector.dart';

class ChatMapper {
  final MediaUrlResolver _media;

  const ChatMapper(this._media);

  Mensaje mensajeDesdeJson(Map<String, dynamic> json) {
    return Mensaje(
      id: JsonLector.entero(json['idMensaje']),
      emisorId: JsonLector.entero(json['idEmisor']),
      contenido: JsonLector.texto(json['contenido']),
      fechaEnvio: JsonLector.fecha(json['fechaEnvio']),
      fechaLectura: JsonLector.fechaOpcional(json['fechaLectura']),
    );
  }

  Contacto contactoDesdeJson(Map<String, dynamic> json) {
    return Contacto(
      id: JsonLector.entero(json['idUsuario']),
      nombre: JsonLector.texto(json['nombre']),
      fotoUrl: _media.resolver(JsonLector.textoOpcional(json['fotoPerfil'])),
    );
  }

  Conversacion conversacionDesdeJson(Map<String, dynamic> json) {
    final otro = contactoDesdeJson(JsonLector.mapa(json['otroParticipante']));
    final ultimo = json['ultimoMensaje'];
    return Conversacion(
      id: JsonLector.entero(json['idConversacion']),
      otroUsuarioId: otro.id,
      otroUsuarioNombre: otro.nombre,
      otroUsuarioFoto: otro.fotoUrl,
      ultimoMensaje: ultimo is Map<String, dynamic> ? mensajeDesdeJson(ultimo) : null,
      fechaActividad: JsonLector.fechaOpcional(json['fechaUltimoMensaje']) ??
          JsonLector.fecha(json['fechaCreacion']),
      mensajesNoLeidos: JsonLector.entero(json['mensajesNoLeidos']),
    );
  }

  ContactoPropiedad contactoPropiedadDesdeJson(Map<String, dynamic> json) {
    final id = json['idConversacion'];
    return ContactoPropiedad(
      conversacionId: id == null ? null : JsonLector.entero(id),
      arrendador: contactoDesdeJson(JsonLector.mapa(json['arrendador'])),
    );
  }

  MensajeEnviado mensajeEnviadoDesdeJson(
    Map<String, dynamic> json, {
    required int conversacionId,
    required String campoMensaje,
  }) {
    return MensajeEnviado(
      conversacionId: conversacionId,
      mensaje: mensajeDesdeJson(JsonLector.mapa(json[campoMensaje])),
      avisoRespuestaLenta: json['avisoRespuestaLenta'] == true,
    );
  }
}
