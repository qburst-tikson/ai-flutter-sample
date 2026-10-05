import 'package:ai_flutter_sample/core/error/failure.dart';
import 'package:ai_flutter_sample/core/usecase/usecase.dart';
import 'package:ai_flutter_sample/features/home/domain/entities/greeting.dart';
import 'package:ai_flutter_sample/features/home/domain/repositories/greeting_repository.dart';
import 'package:ai_flutter_sample/features/home/domain/usecases/get_greeting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGreetingRepository extends Mock implements GreetingRepository {}

void main() {
  late _MockGreetingRepository repository;
  late GetGreeting useCase;

  const greeting = Greeting(title: 'Hi', message: 'Hello there');

  setUp(() {
    repository = _MockGreetingRepository();
    useCase = GetGreeting(repository);
  });

  test('returns the greeting from the repository', () async {
    when(() => repository.getGreeting()).thenAnswer((_) async => greeting);

    final result = await useCase(const NoParams());

    expect(result, greeting);
    verify(() => repository.getGreeting()).called(1);
  });

  test('propagates a Failure from the repository', () async {
    when(() => repository.getGreeting()).thenThrow(const ServerFailure());

    expect(() => useCase(const NoParams()), throwsA(isA<ServerFailure>()));
  });
}
