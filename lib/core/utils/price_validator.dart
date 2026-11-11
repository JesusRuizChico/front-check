class PriceValidator {
  /// Valida que el precio de arrendamiento mensual sea un valor numérico positivo mayor a 0
  static bool isValid(String? price) {
    if (price == null || price.trim().isEmpty) {
      return false;
    }
    final parsed = double.tryParse(price.trim());
    if (parsed == null || parsed <= 0) {
      return false;
    }
    return true;
  }
}
