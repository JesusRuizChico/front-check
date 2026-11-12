import '../models/archivo_imagen.dart';

/// Imagen rechazada antes de enviarse (formato o tamaño no permitido).
class ImagenInvalidaException implements Exception {
  final String mensaje;

  const ImagenInvalidaException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Acceso a la galería del dispositivo.
abstract interface class ISelectorImagenes {
  Future<List<ArchivoImagen>> elegirVarias({required int maximo});

  Future<ArchivoImagen?> elegirUna();
}
