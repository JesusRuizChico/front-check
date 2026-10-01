import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../../../core/network/api_client.dart';

/// Servicio encargado de la comunicación con los endpoints de gestión de perfil
/// Historia de Usuario: HU04 — Actualización de Foto de Perfil
class PerfilService {
  /// Tamaño máximo de archivo permitido (5 MB)
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Extensiones de imagen soportadas por la plataforma
  static const List<String> extensionesValidas = ['jpg', 'jpeg', 'png', 'webp'];

  /// Obtiene los datos del perfil del usuario actualmente autenticado
  Future<Map<String, dynamic>> obtenerMiPerfil() async {
    final response = await apiClient.get('/perfil');
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Error al obtener la información de perfil.');
  }

  /// Escenario 1 y 2: Sube o actualiza la foto de perfil del usuario
  /// Valida en el cliente el tipo de archivo y el tamaño antes de enviarlo
  Future<Map<String, dynamic>> actualizarFotoPerfil(XFile imagen) async {
    // 1. Validar la extensión del archivo
    final nombreArchivo = imagen.name.toLowerCase();
    final tieneExtensionValida = extensionesValidas.any((ext) => nombreArchivo.endsWith('.$ext'));
    if (!tieneExtensionValida) {
      throw Exception('Formato no soportado. Las extensiones permitidas son: .jpg, .jpeg, .png, .webp');
    }

    // 2. Leer bytes y verificar tamaño (máximo 5 MB)
    final Uint8List bytes = await imagen.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('El archivo de imagen seleccionado está vacío.');
    }
    if (bytes.length > maxFileSizeBytes) {
      throw Exception('El tamaño de la imagen no debe exceder los 5 MB.');
    }

    // 3. Detectar el MIME type de la imagen
    final mimeType = lookupMimeType(imagen.name, headerBytes: bytes) ?? 'image/jpeg';
    if (!mimeType.startsWith('image/')) {
      throw Exception('El archivo seleccionado no es una imagen válida.');
    }

    // 4. Construir la petición multipart para el endpoint /api/perfil/foto
    final mediaType = MediaType.parse(mimeType);
    final multipartFile = http.MultipartFile.fromBytes(
      'foto',
      bytes,
      filename: imagen.name,
      contentType: mediaType,
    );

    // 5. Enviar al backend
    final response = await apiClient.postMultipart('/perfil/foto', {}, [multipartFile]);
    return response;
  }

  /// Escenario 3: Elimina la foto de perfil actual del usuario
  /// Restablece el valor en el backend y permite mostrar el avatar predeterminado
  Future<Map<String, dynamic>?> eliminarFotoPerfil() async {
    final response = await apiClient.delete('/perfil/foto');
    return response;
  }
}

/// Instancia global del servicio de perfil
final perfilService = PerfilService();
