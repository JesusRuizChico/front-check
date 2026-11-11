class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String telefono;
  final List<String> roles;
  final String? fotoUrl;
  final String bio;
  final DateTime fechaRegistro;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.roles,
    this.fotoUrl,
    this.bio = 'Usuario de HabitaCheck',
    required this.fechaRegistro,
  });

  bool get esArrendador => roles.contains('arrendador');
  bool get esArrendatario => roles.contains('arrendatario');
  bool get esPrestador => roles.contains('proveedor') || roles.contains('servicios');

  String get rolPrincipal {
    if (esArrendador) return 'Arrendador';
    if (esPrestador) return 'Prestador de Servicios';
    return 'Arrendatario';
  }

  Usuario copyWith({
    int? id,
    String? nombre,
    String? correo,
    String? telefono,
    List<String>? roles,
    String? fotoUrl,
    String? bio,
    DateTime? fechaRegistro,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      roles: roles ?? this.roles,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      bio: bio ?? this.bio,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'roles': roles,
      'fotoUrl': fotoUrl,
      'bio': bio,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int? ?? 1,
      nombre: json['nombre'] as String? ?? 'Usuario',
      correo: json['correo'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? ['arrendatario'],
      fotoUrl: json['fotoUrl'] as String?,
      bio: json['bio'] as String? ?? 'Usuario de HabitaCheck',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(),
    );
  }
}

