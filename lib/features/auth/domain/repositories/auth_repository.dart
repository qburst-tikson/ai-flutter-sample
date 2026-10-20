import '../entities/user.dart';

abstract interface class AuthRepository {
  /// Returns the logged-in [User] on success.
  ///
  /// Throws a `Failure` when the login fails.
  Future<User> login({required String email, required String password});
}
