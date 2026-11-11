class PhoneValidator {
  /// Valida que el número telefónico contenga exactamente 10 dígitos numéricos
  static bool isValid(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return false;
    }
    final cleanPhone = phone.trim();
    if (cleanPhone.length != 10) {
      return false;
    }
    return RegExp(r'^[0-9]{10}$').hasMatch(cleanPhone);
  }
}
