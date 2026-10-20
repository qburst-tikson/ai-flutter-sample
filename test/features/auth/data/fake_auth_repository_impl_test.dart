import 'package:ai_flutter_sample/core/error/failure.dart';
import 'package:ai_flutter_sample/features/auth/data/demo_credentials.dart';
import 'package:ai_flutter_sample/features/auth/data/repositories/fake_auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = FakeAuthRepositoryImpl();

  testWidgets('completes without error for the demo credentials after 1s', (
    tester,
  ) async {
    var completed = false;
    repository
        .login(
          email: DemoCredentials.email,
          password: DemoCredentials.password,
        )
        .then((_) => completed = true);

    await tester.pump(const Duration(milliseconds: 999));
    expect(completed, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    expect(completed, isTrue);
  });

  test('accepts a trimmed, mixed-case email', () async {
    await expectLater(
      repository.login(email: ' Tikson@Qburst.com ', password: 'Avenger123'),
      completes,
    );
  });

  test('returns the trimmed, as-entered email on success', () async {
    final user = await repository.login(
      email: ' Tikson@Qburst.com ',
      password: DemoCredentials.password,
    );

    expect(user.email, 'Tikson@Qburst.com');
  });

  test('rejects a wrong email', () async {
    await expectLater(
      repository.login(email: 'user@example.com', password: 'Avenger123'),
      throwsA(const AuthenticationFailure()),
    );
  });

  test('rejects a wrong password', () async {
    await expectLater(
      repository.login(email: DemoCredentials.email, password: 'abc123'),
      throwsA(const AuthenticationFailure()),
    );
  });

  test('rejects a case-different password', () async {
    await expectLater(
      repository.login(email: DemoCredentials.email, password: 'AVENGER123'),
      throwsA(const AuthenticationFailure()),
    );
  });
}
