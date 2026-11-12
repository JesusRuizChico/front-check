/// Usuario autenticado en HabitaCheck.
class Usuario {
  static const rolArrendador = 'arrendador';
  static const rolArrendatario = 'arrendatario';

  final int id;
  final String nombre;
  final String correo;
  final String? telefono;
  final String? fotoUrl;
  final String? bio;
  final List<String> roles;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    this.telefono,
    this.fotoUrl,
    this.bio,
    required this.roles,
  });

  bool get esArrendador => roles.contains(rolArrendador);

  bool get esArrendatario => roles.contains(rolArrendatario);

  String get rolPrincipal => esArrendador ? 'Arrendador' : 'Inquilino';

  /// Rol de la otra persona en un chat: los chats siempre son entre inquilino y arrendador.
  String get rolContraparte => esArrendador ? 'Inquilino' : 'Arrendador';

  String get primerNombre => nombre.trim().split(RegExp(r'\s+')).first;
}
