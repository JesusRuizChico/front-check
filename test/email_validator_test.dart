import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/utils/email_validator.dart';

void main() {
  group('EmailValidator - Pruebas Unitarias', () {
    test('CP01: Correo universitario institucional válido retorna true', () {
      // ARRANGE
      const inputEmail = 'alumnos.utsjr@utsjr.edu.mx';

      // ACT
      final resultado = EmailValidator.isValid(inputEmail);

      // ASSERT
      expect(resultado, isTrue);
    });

    test('CP02: Correo sin arroba debe retornar false', () {
      // ARRANGE
      const inputEmail = 'usuario.correo.com';

      // ACT
      final resultado = EmailValidator.isValid(inputEmail);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP03: Correo sin dominio ni extensión debe retornar false', () {
      // ARRANGE
      const inputEmail = 'usuario@';

      // ACT
      final resultado = EmailValidator.isValid(inputEmail);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP04: Correo con espacios intercalados debe retornar false', () {
      // ARRANGE
      const inputEmail = 'usuario prueba@correo.com';

      // ACT
      final resultado = EmailValidator.isValid(inputEmail);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP05: Correo nulo o vacío debe retornar false', () {
      // ARRANGE
      const String? inputEmail = null;

      // ACT
      final resultado = EmailValidator.isValid(inputEmail);

      // ASSERT
      expect(resultado, isFalse);
    });
  });
}
