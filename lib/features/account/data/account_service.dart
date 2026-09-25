import '../../../core/network/api_client.dart';

class AccountService {
  Future<Map<String, dynamic>> actualizarContacto(String telefono, String? correoAlterno) async {
    return await apiClient.put('/perfil', {
      'telefono': telefono,
      'correoAlterno': correoAlterno,
    });
  }
}
final accountService = AccountService();
