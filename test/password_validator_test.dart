import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/utils/password_validator.dart';

void main() {
  group('PasswordValidator - Pruebas Unitarias Automatizadas', () {
    test('CP01: Contraseña válida cumple con todas las reglas y retorna true', () {
      // ARRANGE (Preparar)
      const inputPassword = 'HabitaCheck2026';

      // ACT (Actuar / Ejecutar)
      final resultado = PasswordValidator.isValid(inputPassword);

      // ASSERT (Verificar / Afirmar)
      expect(resultado, isTrue);
    });

    test('CP02: Contraseña menor a 8 caracteres debe retornar false', () {
      // ARRANGE (Preparar)
      const inputPassword = 'Ab1';

      // ACT (Actuar / Ejecutar)
      final resultado = PasswordValidator.isValid(inputPassword);

      // ASSERT (Verificar / Afirmar)
      expect(resultado, isFalse);
    });

    test('CP03: Contraseña sin letras mayúsculas debe retornar false', () {
      // ARRANGE (Preparar)
      const inputPassword = 'habitacheck2026';

      // ACT (Actuar / Ejecutar)
      final resultado = PasswordValidator.isValid(inputPassword);

      // ASSERT (Verificar / Afirmar)
      expect(resultado, isFalse);
    });

    test('CP04: Contraseña sin dígitos numéricos debe retornar false', () {
      // ARRANGE (Preparar)
      const inputPassword = 'HabitaCheckSegura';

      // ACT (Actuar / Ejecutar)
      final resultado = PasswordValidator.isValid(inputPassword);

      // ASSERT (Verificar / Afirmar)
      expect(resultado, isFalse);
    });

    test('CP05: Contraseña vacía o con solo espacios debe retornar false', () {
      // ARRANGE (Preparar)
      const inputPassword = '   ';

      // ACT (Actuar / Ejecutar)
      final resultado = PasswordValidator.isValid(inputPassword);

      // ASSERT (Verificar / Afirmar)
      expect(resultado, isFalse);
    });
  });
}
