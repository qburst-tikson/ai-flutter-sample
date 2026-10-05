import '../../../../core/error/failure.dart';
import '../../domain/entities/greeting.dart';
import '../../domain/repositories/greeting_repository.dart';

/// Local, hard-coded implementation so the starter runs without a backend.
///
/// Replace with a remote data source (e.g. dio) when a real API exists.
class GreetingRepositoryImpl implements GreetingRepository {
  const GreetingRepositoryImpl();

  @override
  Future<Greeting> getGreeting() async {
    try {
      // Simulate a short network delay.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return const Greeting(
        title: 'AI Flutter Sample',
        message:
            'Built from Jira tickets by Claude. Ready for your first feature.',
      );
    } on Failure {
      rethrow;
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}
