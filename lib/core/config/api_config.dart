import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Dirección del backend. Se puede cambiar al compilar con
/// `--dart-define=API_URL=http://192.168.1.50:8080` (por ejemplo, para un teléfono físico).
class ApiConfig {
  static const String _urlDefinida = String.fromEnvironment('API_URL');

  const ApiConfig._();

  static String get baseUrl {
    if (_urlDefinida.isNotEmpty) {
      return _urlDefinida.endsWith('/')
          ? _urlDefinida.substring(0, _urlDefinida.length - 1)
          : _urlDefinida;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // El emulador de Android expone la máquina anfitriona en 10.0.2.2.
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
