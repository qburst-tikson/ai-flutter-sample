import '../entities/greeting.dart';

abstract interface class GreetingRepository {
  /// Returns today's greeting.
  ///
  /// Throws a `Failure` if it cannot be loaded.
  Future<Greeting> getGreeting();
}
