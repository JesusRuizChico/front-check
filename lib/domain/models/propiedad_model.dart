class Propiedad {
  final int id;
  final String titulo;
  final String descripcion;
  final double precioMensual;
  final String calle;
  final String numeroExterior;
  final String? numeroInterior;
  final String colonia;
  final String municipio;
  final String estadoUbicacion;
  final String codigoPostal;
  final List<String> imagenes;
  final List<String> servicios;
  final String estado; // 'activa', 'inactiva', 'rentada'
  final int arrendadorId;
  final String arrendadorNombre;
  final String arrendadorTelefono;
  final int habitaciones;
  final int banos;
  final int estacionamientos;
  final double metrosCuadrados;
  final bool esFavorito;
  final DateTime fechaPublicacion;

  const Propiedad({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precioMensual,
    required this.calle,
    required this.numeroExterior,
    this.numeroInterior,
    required this.colonia,
    required this.municipio,
    required this.estadoUbicacion,
    required this.codigoPostal,
    required this.imagenes,
    required this.servicios,
    this.estado = 'activa',
    required this.arrendadorId,
    required this.arrendadorNombre,
    required this.arrendadorTelefono,
    this.habitaciones = 2,
    this.banos = 1,
    this.estacionamientos = 1,
    this.metrosCuadrados = 85.0,
    this.esFavorito = false,
    required this.fechaPublicacion,
  });

  String get direccionCompleta {
    final intStr = numeroInterior != null && numeroInterior!.isNotEmpty ? ' Int. $numeroInterior' : '';
    return '$calle $numeroExterior$intStr, Col. $colonia, $municipio, $estadoUbicacion (C.P. $codigoPostal)';
  }

  String get imagenPrincipal {
    if (imagenes.isNotEmpty) return imagenes.first;
    return 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=800&q=80';
  }

  bool get esActiva => estado.toLowerCase() == 'activa';

  Propiedad copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    double? precioMensual,
    String? calle,
    String? numeroExterior,
    String? numeroInterior,
    String? colonia,
    String? municipio,
    String? estadoUbicacion,
    String? codigoPostal,
    List<String>? imagenes,
    List<String>? servicios,
    String? estado,
    int? arrendadorId,
    String? arrendadorNombre,
    String? arrendadorTelefono,
    int? habitaciones,
    int? banos,
    int? estacionamientos,
    double? metrosCuadrados,
    bool? esFavorito,
    DateTime? fechaPublicacion,
  }) {
    return Propiedad(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      precioMensual: precioMensual ?? this.precioMensual,
      calle: calle ?? this.calle,
      numeroExterior: numeroExterior ?? this.numeroExterior,
      numeroInterior: numeroInterior ?? this.numeroInterior,
      colonia: colonia ?? this.colonia,
      municipio: municipio ?? this.municipio,
      estadoUbicacion: estadoUbicacion ?? this.estadoUbicacion,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      imagenes: imagenes ?? this.imagenes,
      servicios: servicios ?? this.servicios,
      estado: estado ?? this.estado,
      arrendadorId: arrendadorId ?? this.arrendadorId,
      arrendadorNombre: arrendadorNombre ?? this.arrendadorNombre,
      arrendadorTelefono: arrendadorTelefono ?? this.arrendadorTelefono,
      habitaciones: habitaciones ?? this.habitaciones,
      banos: banos ?? this.banos,
      estacionamientos: estacionamientos ?? this.estacionamientos,
      metrosCuadrados: metrosCuadrados ?? this.metrosCuadrados,
      esFavorito: esFavorito ?? this.esFavorito,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precioMensual': precioMensual,
      'calle': calle,
      'numeroExterior': numeroExterior,
      'numeroInterior': numeroInterior,
      'colonia': colonia,
      'municipio': municipio,
      'estadoUbicacion': estadoUbicacion,
      'codigoPostal': codigoPostal,
      'imagenes': imagenes,
      'servicios': servicios,
      'estado': estado,
      'arrendadorId': arrendadorId,
      'arrendadorNombre': arrendadorNombre,
      'arrendadorTelefono': arrendadorTelefono,
      'habitaciones': habitaciones,
      'banos': banos,
      'estacionamientos': estacionamientos,
      'metrosCuadrados': metrosCuadrados,
      'esFavorito': esFavorito,
      'fechaPublicacion': fechaPublicacion.toIso8601String(),
    };
  }

  factory Propiedad.fromJson(Map<String, dynamic> json) {
    return Propiedad(
      id: json['id'] as int? ?? 0,
      titulo: json['titulo'] as String? ?? 'Propiedad',
      descripcion: json['descripcion'] as String? ?? '',
      precioMensual: (json['precioMensual'] is num)
          ? (json['precioMensual'] as num).toDouble()
          : double.tryParse(json['precioMensual']?.toString() ?? '0') ?? 0.0,
      calle: json['calle'] as String? ?? '',
      numeroExterior: json['numeroExterior'] as String? ?? '',
      numeroInterior: json['numeroInterior'] as String?,
      colonia: json['colonia'] as String? ?? '',
      municipio: json['municipio'] as String? ?? '',
      estadoUbicacion: json['estadoUbicacion'] as String? ?? '',
      codigoPostal: json['codigoPostal'] as String? ?? '',
      imagenes: (json['imagenes'] as List<dynamic>?)?.cast<String>() ?? [],
      servicios: (json['servicios'] as List<dynamic>?)?.cast<String>() ?? [],
      estado: json['estado'] as String? ?? 'activa',
      arrendadorId: json['arrendadorId'] as int? ?? 1,
      arrendadorNombre: json['arrendadorNombre'] as String? ?? 'Arrendador',
      arrendadorTelefono: json['arrendadorTelefono'] as String? ?? '',
      habitaciones: json['habitaciones'] as int? ?? 2,
      banos: json['banos'] as int? ?? 1,
      estacionamientos: json['estacionamientos'] as int? ?? 1,
      metrosCuadrados: (json['metrosCuadrados'] is num)
          ? (json['metrosCuadrados'] as num).toDouble()
          : 85.0,
      esFavorito: json['esFavorito'] as bool? ?? false,
      fechaPublicacion: json['fechaPublicacion'] != null
          ? DateTime.tryParse(json['fechaPublicacion'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

