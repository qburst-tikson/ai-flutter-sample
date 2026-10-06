import '../../../../core/error/failure.dart';
import '../../domain/repositories/auth_repository.dart';

/// Placeholder implementation: succeeds for any input after one second.
///
/// Replace with a remote-backed implementation via DI when a real API exists.
class FakeAuthRepositoryImpl implements AuthRepository {
  const FakeAuthRepositoryImpl();

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
    } on Failure {
      rethrow;
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}
