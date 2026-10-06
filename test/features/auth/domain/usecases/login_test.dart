import 'package:ai_flutter_sample/core/error/failure.dart';
import 'package:ai_flutter_sample/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_flutter_sample/features/auth/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late Login login;

  const params = LoginParams(email: 'user@example.com', password: 'secret1');

  setUp(() {
    repository = _MockAuthRepository();
    login = Login(repository);
  });

  test('delegates to the repository', () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});

    await login(params);

    verify(
      () => repository.login(email: 'user@example.com', password: 'secret1'),
    ).called(1);
  });

  test('propagates failures', () {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const ServerFailure());

    expect(() => login(params), throwsA(const ServerFailure()));
  });
}
