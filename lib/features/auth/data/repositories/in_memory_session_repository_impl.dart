import '../../domain/entities/user.dart';
import '../../domain/repositories/session_repository.dart';

/// In-memory [SessionRepository]: a plain mutable field, no persistence.
///
/// State is lost on app restart or process death (out of scope for now).
class InMemorySessionRepositoryImpl implements SessionRepository {
  User? _user;

  @override
  User? get currentUser => _user;

  @override
  void save(User user) => _user = user;

  @override
  void clear() => _user = null;
}
