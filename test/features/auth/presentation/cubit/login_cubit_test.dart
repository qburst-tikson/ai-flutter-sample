import 'package:ai_flutter_sample/core/error/failure.dart';
import 'package:ai_flutter_sample/features/auth/domain/usecases/login.dart';
import 'package:ai_flutter_sample/features/auth/domain/validators/login_validator.dart';
import 'package:ai_flutter_sample/features/auth/presentation/cubit/login_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogin extends Mock implements Login {}

void main() {
  late _MockLogin login;

  const email = 'user@example.com';
  const password = 'secret1';

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  setUp(() {
    login = _MockLogin();
  });

  test('initial state is LoginInitial', () {
    expect(LoginCubit(login).state, const LoginInitial());
  });

  blocTest<LoginCubit, LoginState>(
    'emits [LoginInvalid] with an email error for an invalid email',
    build: () => LoginCubit(login),
    act: (cubit) => cubit.login('nope', password),
    expect: () => const [
      LoginInvalid(emailError: LoginValidator.emailInvalidMessage),
    ],
    verify: (_) => verifyNever(() => login(any())),
  );

  blocTest<LoginCubit, LoginState>(
    'emits [LoginInvalid] with a password error for a short password',
    build: () => LoginCubit(login),
    act: (cubit) => cubit.login(email, '123'),
    expect: () => const [
      LoginInvalid(passwordError: LoginValidator.passwordTooShortMessage),
    ],
    verify: (_) => verifyNever(() => login(any())),
  );

  blocTest<LoginCubit, LoginState>(
    'emits [LoginInvalid] with both errors when both fields are empty',
    build: () => LoginCubit(login),
    act: (cubit) => cubit.login('', ''),
    expect: () => const [
      LoginInvalid(
        emailError: LoginValidator.emailRequiredMessage,
        passwordError: LoginValidator.passwordRequiredMessage,
      ),
    ],
    verify: (_) => verifyNever(() => login(any())),
  );

  blocTest<LoginCubit, LoginState>(
    'emits [Loading, Success] for valid input and trims the email',
    setUp: () {
      when(() => login(any())).thenAnswer((_) async {});
    },
    build: () => LoginCubit(login),
    act: (cubit) => cubit.login('  $email ', password),
    expect: () => const [LoginLoading(), LoginSuccess()],
    verify: (_) {
      verify(
        () => login(const LoginParams(email: email, password: password)),
      ).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'emits [Loading, Error] with the failure message on Failure',
    setUp: () {
      when(() => login(any())).thenThrow(const NetworkFailure());
    },
    build: () => LoginCubit(login),
    act: (cubit) => cubit.login(email, password),
    expect: () => const [
      LoginLoading(),
      LoginError('No internet connection.'),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'emits [Loading, Error] with a generic message on unknown errors',
    setUp: () {
      when(() => login(any())).thenThrow(StateError('boom'));
    },
    build: () => LoginCubit(login),
    act: (cubit) => cubit.login(email, password),
    expect: () => const [
      LoginLoading(),
      LoginError('Something went wrong.'),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'ignores a second login call while loading',
    setUp: () {
      when(() => login(any())).thenAnswer((_) async {});
    },
    build: () => LoginCubit(login),
    act: (cubit) {
      cubit.login(email, password);
      cubit.login(email, password);
    },
    expect: () => const [LoginLoading(), LoginSuccess()],
    verify: (_) => verify(() => login(any())).called(1),
  );

  group('clearFieldError', () {
    const both = LoginInvalid(
      emailError: LoginValidator.emailRequiredMessage,
      passwordError: LoginValidator.passwordRequiredMessage,
    );

    blocTest<LoginCubit, LoginState>(
      'clears only the edited field',
      build: () => LoginCubit(login),
      seed: () => both,
      act: (cubit) => cubit.clearFieldError(email: true),
      expect: () => const [
        LoginInvalid(passwordError: LoginValidator.passwordRequiredMessage),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'returns to LoginInitial once no errors remain',
      build: () => LoginCubit(login),
      seed: () =>
          const LoginInvalid(emailError: LoginValidator.emailInvalidMessage),
      act: (cubit) => cubit.clearFieldError(email: true),
      expect: () => const [LoginInitial()],
    );

    blocTest<LoginCubit, LoginState>(
      'does nothing when the edited field has no error',
      build: () => LoginCubit(login),
      seed: () =>
          const LoginInvalid(emailError: LoginValidator.emailInvalidMessage),
      act: (cubit) => cubit.clearFieldError(password: true),
      expect: () => const <LoginState>[],
    );

    blocTest<LoginCubit, LoginState>(
      'does nothing outside LoginInvalid',
      build: () => LoginCubit(login),
      act: (cubit) => cubit.clearFieldError(email: true, password: true),
      expect: () => const <LoginState>[],
    );
  });
}
