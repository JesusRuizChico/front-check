/// Error devuelto por el backend o por la conexión con él.
class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;

  const ApiException(this.mensaje, {this.statusCode});

  bool get esNoAutorizado => statusCode == 401;

  @override
  String toString() => mensaje;
}
