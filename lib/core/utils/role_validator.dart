class RoleValidator {
  /// Valida que el rol solicitado en el registro sea uno de los perfiles públicos:
  /// 'arrendatario' (inquilino) o 'arrendador'.
  static bool isValid(String? role) {
    if (role == null || role.trim().isEmpty) {
      return false;
    }
    const rolesValidos = ['arrendatario', 'arrendador'];
    return rolesValidos.contains(role.trim().toLowerCase());
  }
}
