import 'dart:typed_data';

/// Identifica el formato real de una imagen por su contenido.
class FormatoImagen {
  static const int tamanoMaximoBytes = 5 * 1024 * 1024;

  const FormatoImagen._();

  /// Devuelve la extensión (`jpg`, `png` o `webp`) o `null` si no es un formato admitido.
  static String? extension(Uint8List bytes) {
    if (_empiezaCon(bytes, const [0xFF, 0xD8, 0xFF])) return 'jpg';
    if (_empiezaCon(bytes, const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) return 'png';
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'webp';
    }
    return null;
  }

  static bool _empiezaCon(Uint8List bytes, List<int> firma) {
    if (bytes.length < firma.length) return false;
    for (var i = 0; i < firma.length; i++) {
      if (bytes[i] != firma[i]) return false;
    }
    return true;
  }
}
