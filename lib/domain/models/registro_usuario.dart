/// Datos de alta de una cuenta nueva.
class RegistroUsuario {
  final String nombre;
  final String correo;
  final String contrasena;
  final String telefono;
  final String rol;

  const RegistroUsuario({
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.telefono,
    required this.rol,
  });
}
