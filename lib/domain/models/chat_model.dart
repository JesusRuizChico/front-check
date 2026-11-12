/// Mensaje dentro de una conversación.
class Mensaje {
  final int id;
  final int emisorId;
  final String contenido;
  final DateTime fechaEnvio;
  final DateTime? fechaLectura;

  const Mensaje({
    required this.id,
    required this.emisorId,
    required this.contenido,
    required this.fechaEnvio,
    this.fechaLectura,
  });

  bool esMio(int miUsuarioId) => emisorId == miUsuarioId;

  bool get leido => fechaLectura != null;
}

/// Resumen de un chat entre un inquilino y un arrendador.
class Conversacion {
  final int id;
  final int otroUsuarioId;
  final String otroUsuarioNombre;
  final String? otroUsuarioFoto;
  final Mensaje? ultimoMensaje;
  final DateTime fechaActividad;
  final int mensajesNoLeidos;

  const Conversacion({
    required this.id,
    required this.otroUsuarioId,
    required this.otroUsuarioNombre,
    this.otroUsuarioFoto,
    this.ultimoMensaje,
    required this.fechaActividad,
    required this.mensajesNoLeidos,
  });
}

/// Persona con la que se conversa.
class Contacto {
  final int id;
  final String nombre;
  final String? fotoUrl;

  const Contacto({required this.id, required this.nombre, this.fotoUrl});
}

/// Resultado de buscar el chat asociado al arrendador de una propiedad.
class ContactoPropiedad {
  final int? conversacionId;
  final Contacto arrendador;

  const ContactoPropiedad({this.conversacionId, required this.arrendador});
}

/// Resultado de enviar un mensaje.
class MensajeEnviado {
  final int conversacionId;
  final Mensaje mensaje;
  final bool avisoRespuestaLenta;

  const MensajeEnviado({
    required this.conversacionId,
    required this.mensaje,
    required this.avisoRespuestaLenta,
  });
}
