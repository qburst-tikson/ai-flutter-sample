import '../entities/user.dart';

/// Holds the logged-in [User] for the lifetime of the process.
abstract interface class SessionRepository {
  /// The current user, or `null` when nobody is logged in.
  User? get currentUser;

  /// Saves [user], replacing any previous one.
  void save(User user);

  /// Clears the session (after logout).
  void clear();
}
