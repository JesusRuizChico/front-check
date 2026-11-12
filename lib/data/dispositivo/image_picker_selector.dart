import 'package:image_picker/image_picker.dart';

import '../../domain/models/archivo_imagen.dart';
import '../../domain/servicios/selector_imagenes.dart';
import 'formato_imagen.dart';

/// Selecciona imágenes de la galería y las prepara para el backend.
class ImagePickerSelector implements ISelectorImagenes {
  final ImagePicker _picker;

  ImagePickerSelector([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  @override
  Future<List<ArchivoImagen>> elegirVarias({required int maximo}) async {
    if (maximo <= 0) return const [];
    final archivos = maximo == 1
        ? [await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1920)]
            .whereType<XFile>()
            .toList()
        : await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1920, limit: maximo);
    final imagenes = <ArchivoImagen>[];
    for (final archivo in archivos.take(maximo)) {
      imagenes.add(await _convertir(archivo));
    }
    return imagenes;
  }

  @override
  Future<ArchivoImagen?> elegirUna() async {
    final archivo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1080);
    return archivo == null ? null : _convertir(archivo);
  }

  Future<ArchivoImagen> _convertir(XFile archivo) async {
    final bytes = await archivo.readAsBytes();
    final extension = FormatoImagen.extension(bytes);
    if (extension == null) {
      throw const ImagenInvalidaException('Solo se permiten imágenes JPG, PNG o WEBP.');
    }
    if (bytes.length > FormatoImagen.tamanoMaximoBytes) {
      throw const ImagenInvalidaException('Cada imagen debe pesar como máximo 5 MB.');
    }
    // El nombre se normaliza con la extensión real para que coincida con su contenido.
    return ArchivoImagen(nombre: 'imagen_${DateTime.now().microsecondsSinceEpoch}.$extension', bytes: bytes);
  }
}
