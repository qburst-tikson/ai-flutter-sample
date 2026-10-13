import 'package:ai_flutter_sample/features/home/data/repositories/greeting_repository_impl.dart';
import 'package:ai_flutter_sample/features/home/domain/entities/greeting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GreetingRepositoryImpl', () {
    test('getGreeting returns the demo greeting', () async {
      const repository = GreetingRepositoryImpl();

      final greeting = await repository.getGreeting();

      expect(
        greeting,
        const Greeting(
          title: 'AI Flutter Demo',
          message: 'Welcome! This app is built from Jira tickets.',
        ),
      );
    });
  });
}
