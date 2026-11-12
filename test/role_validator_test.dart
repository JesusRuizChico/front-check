import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/utils/role_validator.dart';

void main() {
  group('RoleValidator - Pruebas Unitarias', () {
    test('CP01: Rol arrendatario válido retorna true', () {
      // ARRANGE
      const inputRole = 'arrendatario';

      // ACT
      final resultado = RoleValidator.isValid(inputRole);

      // ASSERT
      expect(resultado, isTrue);
    });

    test('CP02: Rol arrendador válido retorna true', () {
      // ARRANGE
      const inputRole = 'arrendador';

      // ACT
      final resultado = RoleValidator.isValid(inputRole);

      // ASSERT
      expect(resultado, isTrue);
    });

    test('CP03: Rol de prestador de servicios ya no es válido', () {
      // ARRANGE
      const inputRole = 'servicios';

      // ACT
      final resultado = RoleValidator.isValid(inputRole);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP04: Rol no reconocido debe retornar false', () {
      // ARRANGE
      const inputRole = 'administrador';

      // ACT
      final resultado = RoleValidator.isValid(inputRole);

      // ASSERT
      expect(resultado, isFalse);
    });

    test('CP05: Rol vacío o nulo debe retornar false', () {
      // ARRANGE
      const String? inputRole = null;

      // ACT
      final resultado = RoleValidator.isValid(inputRole);

      // ASSERT
      expect(resultado, isFalse);
    });
  });
}
