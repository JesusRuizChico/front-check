class PasswordValidator {
  /// Valida los requisitos mínimos de seguridad para contraseñas de la plataforma:
  /// 1. Longitud mínima de 8 caracteres.
  /// 2. Al menos una letra mayúscula [A-Z].
  /// 3. Al menos un dígito numérico [0-9].
  static bool isValid(String? password) {
    if (password == null || password.trim().isEmpty) {
      return false;
    }
    if (password.length < 8) {
      return false;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }
    return true;
  }
}
