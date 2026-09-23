import '../../../core/network/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    return await apiClient.post('/auth/login', {
      'correo': correo,
      'contrasena': contrasena,
    });
  }

  Future<Map<String, dynamic>> register(
    String nombre,
    String correo,
    String contrasena,
    String telefono,
    String rolSolicitado,
  ) async {
    return await apiClient.post('/auth/registro', {
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
      'telefono': telefono,
      'rolSolicitado': rolSolicitado,
    });
  }
}

final authService = AuthService();
