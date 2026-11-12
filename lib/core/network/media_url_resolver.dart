/// Convierte las rutas de imágenes que guarda el backend (`/uploads/...`)
/// en URLs completas que el dispositivo puede descargar.
class MediaUrlResolver {
  final String baseUrl;

  const MediaUrlResolver(this.baseUrl);

  String? resolver(String? ruta) {
    if (ruta == null || ruta.trim().isEmpty) return null;
    if (ruta.startsWith('http://') || ruta.startsWith('https://')) return ruta;
    return ruta.startsWith('/') ? '$baseUrl$ruta' : '$baseUrl/$ruta';
  }
}
