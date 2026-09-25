import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/utils/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    test('Contraseña válida debe retornar true', () {
      expect(PasswordValidator.isValid('Abcd12345'), isTrue);
    });

    test('Contraseña corta debe retornar false', () {
      expect(PasswordValidator.isValid('Abc1'), isFalse);
    });

    test('Contraseña sin mayúsculas debe retornar false', () {
      expect(PasswordValidator.isValid('abcd12345'), isFalse);
    });

    test('Contraseña sin números debe retornar false', () {
      expect(PasswordValidator.isValid('Abcdefghi'), isFalse);
    });
  });
}
