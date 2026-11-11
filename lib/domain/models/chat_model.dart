class Mensaje {
  final String id;
  final int emisorId;
  final int receptorId;
  final String contenido;
  final DateTime fechaHora;
  final bool leido;

  const Mensaje({
    required this.id,
    required this.emisorId,
    required this.receptorId,
    required this.contenido,
    required this.fechaHora,
    this.leido = true,
  });

  bool esMio(int miUsuarioId) => emisorId == miUsuarioId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emisorId': emisorId,
      'receptorId': receptorId,
      'contenido': contenido,
      'fechaHora': fechaHora.toIso8601String(),
      'leido': leido,
    };
  }

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] as String? ?? 'msg_${DateTime.now().microsecondsSinceEpoch}',
      emisorId: json['emisorId'] as int? ?? 0,
      receptorId: json['receptorId'] as int? ?? 0,
      contenido: json['contenido'] as String? ?? '',
      fechaHora: json['fechaHora'] != null
          ? DateTime.tryParse(json['fechaHora'].toString()) ?? DateTime.now()
          : DateTime.now(),
      leido: json['leido'] as bool? ?? true,
    );
  }
}

class Conversacion {
  final String id;
  final int otroUsuarioId;
  final String otroUsuarioNombre;
  final String? otroUsuarioFoto;
  final String otroUsuarioRol;
  final int? propiedadId;
  final String? propiedadTitulo;
  final String ultimoMensaje;
  final DateTime fechaUltimoMensaje;
  final int mensajesNoLeidos;
  final List<Mensaje> mensajes;

  const Conversacion({
    required this.id,
    required this.otroUsuarioId,
    required this.otroUsuarioNombre,
    this.otroUsuarioFoto,
    required this.otroUsuarioRol,
    this.propiedadId,
    this.propiedadTitulo,
    required this.ultimoMensaje,
    required this.fechaUltimoMensaje,
    this.mensajesNoLeidos = 0,
    required this.mensajes,
  });

  Conversacion copyWith({
    String? id,
    int? otroUsuarioId,
    String? otroUsuarioNombre,
    String? otroUsuarioFoto,
    String? otroUsuarioRol,
    int? propiedadId,
    String? propiedadTitulo,
    String? ultimoMensaje,
    DateTime? fechaUltimoMensaje,
    int? mensajesNoLeidos,
    List<Mensaje>? mensajes,
  }) {
    return Conversacion(
      id: id ?? this.id,
      otroUsuarioId: otroUsuarioId ?? this.otroUsuarioId,
      otroUsuarioNombre: otroUsuarioNombre ?? this.otroUsuarioNombre,
      otroUsuarioFoto: otroUsuarioFoto ?? this.otroUsuarioFoto,
      otroUsuarioRol: otroUsuarioRol ?? this.otroUsuarioRol,
      propiedadId: propiedadId ?? this.propiedadId,
      propiedadTitulo: propiedadTitulo ?? this.propiedadTitulo,
      ultimoMensaje: ultimoMensaje ?? this.ultimoMensaje,
      fechaUltimoMensaje: fechaUltimoMensaje ?? this.fechaUltimoMensaje,
      mensajesNoLeidos: mensajesNoLeidos ?? this.mensajesNoLeidos,
      mensajes: mensajes ?? this.mensajes,
    );
  }
}

