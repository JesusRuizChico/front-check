import '../../../core/network/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    return await apiClient.post('/auth/login', {
      'correo': correo,
      'contrasena': contrasena,
    });
  }

  /// Registra un nuevo usuario en el sistema.
  ///
  /// El parámetro [especialidades] es obligatorio únicamente cuando
  /// [rolSolicitado] es 'servicios'. Para otros roles se ignora.
  /// Principio OCP: parámetro opcional, sin romper llamadores existentes.
  Future<Map<String, dynamic>> register(
    String nombre,
    String correo,
    String contrasena,
    String telefono,
    String rolSolicitado, {
    List<String> especialidades = const [],
  }) async {
    final body = <String, dynamic>{
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
      'telefono': telefono,
      'rolSolicitado': rolSolicitado,
    };

    // Solo se envía especialidades si el rol lo requiere
    if (rolSolicitado == 'servicios') {
      body['especialidades'] = especialidades;
    }

    return await apiClient.post('/auth/registro', body);
  }
}

final authService = AuthService();
