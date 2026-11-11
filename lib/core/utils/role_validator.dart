class RoleValidator {
  /// Valida que el rol asignado sea válido dentro del ecosistema de la plataforma:
  /// 'arrendatario', 'arrendador' o 'servicios'
  static bool isValid(String? role) {
    if (role == null || role.trim().isEmpty) {
      return false;
    }
    const rolesValidos = ['arrendatario', 'arrendador', 'servicios'];
    return rolesValidos.contains(role.trim().toLowerCase());
  }
}
