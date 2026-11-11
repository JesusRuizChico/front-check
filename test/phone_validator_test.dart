import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/utils/phone_validator.dart';

void main() {
  group('PhoneValidator - Pruebas Unitarias', () {
    test('CP01: Número celular válido de 10 dígitos retorna true', () {
      // ARRANGE
      const inputPhone = '4271234567';

      // ACT
      final resultado = PhoneValidator.isValid(inputPhone);

      // ASSERT
      expect(resultado, isTrue);
    });

    test('CP02: Número con menos de 10 dígitos debe retornar false', () {
      // ARRANGE
      const inputPhone = '42712345';

      // ACT
      final resultado = PhoneValidator.isValid(inputPhone);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP03: Número con más de 10 dígitos debe retornar false', () {
      // ARRANGE
      const inputPhone = '427123456789';

      // ACT
      final resultado = PhoneValidator.isValid(inputPhone);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP04: Número con caracteres alfabéticos debe retornar false', () {
      // ARRANGE
      const inputPhone = '427123abcd';

      // ACT
      final resultado = PhoneValidator.isValid(inputPhone);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP05: Teléfono vacío debe retornar false', () {
      // ARRANGE
      const inputPhone = '';

      // ACT
      final resultado = PhoneValidator.isValid(inputPhone);

      // ASSERT
      expect(resultado, isFalse);
    });
  });
}
