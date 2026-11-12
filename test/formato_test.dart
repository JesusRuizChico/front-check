import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/utils/formato.dart';
import 'package:front_check/data/dispositivo/formato_imagen.dart';

void main() {
  test('Formato.moneda agrega separador de miles', () {
    expect(Formato.moneda(12500), r'$12,500');
    expect(Formato.moneda(950), r'$950');
    expect(Formato.moneda(1250000), r'$1,250,000');
  });

  test('FormatoImagen detecta el tipo real por su contenido', () {
    expect(FormatoImagen.extension(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0])), 'jpg');
    expect(
      FormatoImagen.extension(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0])),
      'png',
    );
    expect(FormatoImagen.extension(Uint8List.fromList('RIFF0000WEBPVP8 '.codeUnits)), 'webp');
    expect(FormatoImagen.extension(Uint8List.fromList('GIF89a'.codeUnits)), isNull);
  });
}
