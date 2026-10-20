import '../../../../core/usecase/usecase.dart';
import '../repositories/session_repository.dart';

/// Clears the in-memory session on logout.
class Logout implements UseCase<void, NoParams> {
  const Logout(this._sessionRepository);

  final SessionRepository _sessionRepository;

  @override
  Future<void> call(NoParams params) async => _sessionRepository.clear();
}
