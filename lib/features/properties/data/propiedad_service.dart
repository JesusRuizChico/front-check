import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/network/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class PropiedadService {
  Future<void> publicarPropiedad({
    required String titulo,
    required String descripcion,
    required String precioMensual,
    required String calle,
    required String numeroExterior,
    String? numeroInterior,
    required String colonia,
    required String municipio,
    required String estadoUbicacion,
    required String codigoPostal,
    required List<XFile> imagenes,
  }) async {
    final fields = {
      'titulo': titulo,
      'descripcion': descripcion,
      'precioMensual': precioMensual,
      'calle': calle,
      'numeroExterior': numeroExterior,
      if (numeroInterior != null && numeroInterior.isNotEmpty) 'numeroInterior': numeroInterior,
      'colonia': colonia,
      'municipio': municipio,
      'estadoUbicacion': estadoUbicacion,
      'codigoPostal': codigoPostal,
    };

    final files = <http.MultipartFile>[];
    
    for (var i = 0; i < imagenes.length; i++) {
      final img = imagenes[i];
      final byteData = await img.readAsBytes();
      final mimeType = lookupMimeType(img.name, headerBytes: byteData) ?? 'image/jpeg';
      final mediaType = MediaType.parse(mimeType);
      
      files.add(
        http.MultipartFile.fromBytes(
          'imagenes',
          byteData,
          filename: img.name,
          contentType: mediaType,
        ),
      );
    }

    await apiClient.postMultipart('/propiedades', fields, files);
  }

  Future<List<dynamic>> obtenerMisPropiedades() async {
    final response = await apiClient.get('/propiedades/mis-propiedades');
    if (response is List) {
      return response;
    } else if (response == null) {
      return [];
    }
    throw Exception('Error al cargar propiedades');
  }

  Future<Map<String, dynamic>> editarPropiedad({
    required int idPropiedad,
    required String titulo,
    required String descripcion,
    required String precioMensual,
    required String calle,
    required String numeroExterior,
    String? numeroInterior,
    required String colonia,
    required String municipio,
    required String estadoUbicacion,
    required String codigoPostal,
  }) async {
    final body = <String, dynamic>{
      'titulo': titulo,
      'descripcion': descripcion,
      'precioMensual': double.tryParse(precioMensual) ?? 0,
      'calle': calle,
      'numeroExterior': numeroExterior,
      'numeroInterior': numeroInterior ?? '',
      'colonia': colonia,
      'municipio': municipio,
      'estadoUbicacion': estadoUbicacion,
      'codigoPostal': codigoPostal,
    };

    return await apiClient.put('/propiedades/$idPropiedad', body);
  }
}

final propiedadService = PropiedadService();
