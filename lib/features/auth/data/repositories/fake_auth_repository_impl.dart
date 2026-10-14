import '../../../../core/error/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../demo_credentials.dart';

/// Fake implementation that accepts only the demo account after one second.
///
/// Replace with a remote-backed implementation via DI when a real API exists.
class FakeAuthRepositoryImpl implements AuthRepository {
  const FakeAuthRepositoryImpl();

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      final matchesEmail = email.trim().toLowerCase() == DemoCredentials.email;
      if (!matchesEmail || password != DemoCredentials.password) {
        throw const AuthenticationFailure();
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}
