class EmailValidator {
  /// Valida que el correo electrónico tenga una estructura estándar:
  /// usuario@dominio.extension
  static bool isValid(String? email) {
    if (email == null || email.trim().isEmpty) {
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }
}
