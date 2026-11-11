class ServicioMantenimiento {
  final int id;
  final String nombre;
  final String especialidad;
  final String descripcion;
  final double tarifaBase;
  final double calificacion;
  final int trabajosRealizados;
  final String telefono;
  final String fotoUrl;
  final bool disponible;
  final List<String> serviciosOfrecidos;

  const ServicioMantenimiento({
    required this.id,
    required this.nombre,
    required this.especialidad,
    required this.descripcion,
    required this.tarifaBase,
    required this.calificacion,
    required this.trabajosRealizados,
    required this.telefono,
    required this.fotoUrl,
    this.disponible = true,
    required this.serviciosOfrecidos,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'especialidad': especialidad,
      'descripcion': descripcion,
      'tarifaBase': tarifaBase,
      'calificacion': calificacion,
      'trabajosRealizados': trabajosRealizados,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'disponible': disponible,
      'serviciosOfrecidos': serviciosOfrecidos,
    };
  }

  factory ServicioMantenimiento.fromJson(Map<String, dynamic> json) {
    return ServicioMantenimiento(
      id: json['id'] as int? ?? 1,
      nombre: json['nombre'] as String? ?? '',
      especialidad: json['especialidad'] as String? ?? 'General',
      descripcion: json['descripcion'] as String? ?? '',
      tarifaBase: (json['tarifaBase'] is num)
          ? (json['tarifaBase'] as num).toDouble()
          : 350.0,
      calificacion: (json['calificacion'] is num)
          ? (json['calificacion'] as num).toDouble()
          : 4.8,
      trabajosRealizados: json['trabajosRealizados'] as int? ?? 15,
      telefono: json['telefono'] as String? ?? '',
      fotoUrl: json['fotoUrl'] as String? ?? '',
      disponible: json['disponible'] as bool? ?? true,
      serviciosOfrecidos: (json['serviciosOfrecidos'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

