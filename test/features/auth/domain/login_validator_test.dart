import 'package:ai_flutter_sample/features/auth/domain/validators/login_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateEmail', () {
    test('accepts a valid email', () {
      expect(LoginValidator.validateEmail('user@example.com'), isNull);
    });

    test('trims surrounding whitespace', () {
      expect(LoginValidator.validateEmail('  user@example.com '), isNull);
    });

    test('rejects empty and whitespace-only input as required', () {
      expect(
        LoginValidator.validateEmail(''),
        LoginValidator.emailRequiredMessage,
      );
      expect(
        LoginValidator.validateEmail('   '),
        LoginValidator.emailRequiredMessage,
      );
    });

    for (final email in [
      'userexample.com',
      'user@',
      'user@example',
      'a b@c.d'
    ]) {
      test('rejects $email', () {
        expect(
          LoginValidator.validateEmail(email),
          LoginValidator.emailInvalidMessage,
        );
      });
    }
  });

  group('validatePassword', () {
    test('rejects empty', () {
      expect(
        LoginValidator.validatePassword(''),
        LoginValidator.passwordRequiredMessage,
      );
    });

    test('rejects fewer than 6 characters', () {
      expect(
        LoginValidator.validatePassword('12345'),
        LoginValidator.passwordTooShortMessage,
      );
    });

    test('length message wins for a short mixed password', () {
      expect(
        LoginValidator.validatePassword('ab12'),
        LoginValidator.passwordTooShortMessage,
      );
    });

    test('rejects letters only even with 6 characters', () {
      expect(
        LoginValidator.validatePassword('abcdef'),
        LoginValidator.passwordLettersAndNumbersMessage,
      );
    });

    test('rejects numbers only even with 6 characters', () {
      expect(
        LoginValidator.validatePassword('123456'),
        LoginValidator.passwordLettersAndNumbersMessage,
      );
    });

    test('accepts letters and numbers', () {
      expect(LoginValidator.validatePassword('abc123'), isNull);
      expect(LoginValidator.validatePassword('Avenger123'), isNull);
    });
  });
}
