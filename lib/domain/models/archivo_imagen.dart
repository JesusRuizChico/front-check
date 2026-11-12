import 'dart:typed_data';

/// Imagen elegida en el dispositivo, lista para enviarse al servidor.
class ArchivoImagen {
  final String nombre;
  final Uint8List bytes;

  const ArchivoImagen({required this.nombre, required this.bytes});
}
