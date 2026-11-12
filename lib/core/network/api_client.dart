import 'dart:typed_data';

/// Archivo que se envía en una petición multipart.
class ArchivoMultipart {
  final String campo;
  final String nombre;
  final Uint8List bytes;

  const ArchivoMultipart({
    required this.campo,
    required this.nombre,
    required this.bytes,
  });
}

/// Contrato de comunicación con la API REST de HabitaCheck.
abstract interface class ApiClient {
  /// Emite un evento cuando el backend indica que la sesión ya no es válida.
  Stream<void> get sesionExpirada;

  Future<dynamic> get(String ruta);

  Future<dynamic> post(String ruta, [Object? cuerpo]);

  Future<dynamic> put(String ruta, [Object? cuerpo]);

  Future<dynamic> patch(String ruta, [Object? cuerpo]);

  Future<dynamic> delete(String ruta);

  Future<dynamic> postMultipart(
    String ruta, {
    Map<String, String> campos = const {},
    List<ArchivoMultipart> archivos = const [],
  });

  /// Olvida cookies y token CSRF (al cerrar sesión).
  void reiniciar();
}
