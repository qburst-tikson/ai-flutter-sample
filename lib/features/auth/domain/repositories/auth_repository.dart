abstract interface class AuthRepository {
  /// Throws a `Failure` when the login fails.
  Future<void> login({required String email, required String password});
}
