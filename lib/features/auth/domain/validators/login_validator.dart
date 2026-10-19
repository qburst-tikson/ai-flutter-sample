/// Pure validation rules for the login form. Return `null` when valid.
abstract final class LoginValidator {
  static const minPasswordLength = 6;
  static const emailRequiredMessage = 'Email is required';
  static const emailInvalidMessage = 'Enter a valid email address';
  static const passwordRequiredMessage = 'Password is required';
  static const passwordTooShortMessage =
      'Password must be at least $minPasswordLength characters';
  static const passwordLettersAndNumbersMessage =
      'Password must contain both letters and numbers';

  static final _letterRegex = RegExp(r'[A-Za-z]');
  static final _numberRegex = RegExp(r'[0-9]');

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateEmail(String email) {
    final value = email.trim();
    if (value.isEmpty) return emailRequiredMessage;
    if (!_emailRegex.hasMatch(value)) return emailInvalidMessage;
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return passwordRequiredMessage;
    if (password.length < minPasswordLength) return passwordTooShortMessage;
    if (!_letterRegex.hasMatch(password) || !_numberRegex.hasMatch(password)) {
      return passwordLettersAndNumbersMessage;
    }
    return null;
  }
}
