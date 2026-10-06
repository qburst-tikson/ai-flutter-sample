/// Pure validation rules for the login form. Return `null` when valid.
abstract final class LoginValidator {
  static const minPasswordLength = 6;
  static const emailRequiredMessage = 'Email is required';
  static const emailInvalidMessage = 'Enter a valid email address';
  static const passwordRequiredMessage = 'Password is required';
  static const passwordTooShortMessage =
      'Password must be at least $minPasswordLength characters';

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
    return null;
  }
}
