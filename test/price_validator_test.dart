import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/utils/price_validator.dart';

void main() {
  group('PriceValidator - Pruebas Unitarias', () {
    test('CP01: Monto positivo de renta válido retorna true', () {
      // ARRANGE
      const inputPrice = '2500.00';

      // ACT
      final resultado = PriceValidator.isValid(inputPrice);

      // ASSERT
      expect(resultado, isTrue);
    });

    test('CP02: Monto cero debe retornar false', () {
      // ARRANGE
      const inputPrice = '0';

      // ACT
      final resultado = PriceValidator.isValid(inputPrice);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP03: Monto negativo debe retornar false', () {
      // ARRANGE
      const inputPrice = '-1500';

      // ACT
      final resultado = PriceValidator.isValid(inputPrice);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP04: Monto con caracteres no numéricos debe retornar false', () {
      // ARRANGE
      const inputPrice = 'dos mil quinientos';

      // ACT
      final resultado = PriceValidator.isValid(inputPrice);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP05: Monto vacío debe retornar false', () {
      // ARRANGE
      const inputPrice = '   ';

      // ACT
      final resultado = PriceValidator.isValid(inputPrice);

      // ASSERT
      expect(resultado, isFalse);
    });
  });
}
