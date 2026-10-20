import 'package:ai_flutter_sample/core/error/failure.dart';
import 'package:ai_flutter_sample/core/usecase/usecase.dart';
import 'package:ai_flutter_sample/features/auth/domain/usecases/logout.dart';
import 'package:ai_flutter_sample/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogout extends Mock implements Logout {}

void main() {
  late _MockLogout logout;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    logout = _MockLogout();
  });

  test('initial state is LogoutInitial', () {
    expect(LogoutCubit(logout).state, const LogoutInitial());
  });

  blocTest<LogoutCubit, LogoutState>(
    'emits [LogoutInProgress, LogoutSuccess] when logout succeeds',
    setUp: () {
      when(() => logout(any())).thenAnswer((_) async {});
    },
    build: () => LogoutCubit(logout),
    act: (cubit) => cubit.logout(),
    expect: () => const [LogoutInProgress(), LogoutSuccess()],
  );

  blocTest<LogoutCubit, LogoutState>(
    'emits [LogoutInProgress, LogoutFailure] with the failure message on '
    'Failure',
    setUp: () {
      when(() => logout(any())).thenThrow(const NetworkFailure());
    },
    build: () => LogoutCubit(logout),
    act: (cubit) => cubit.logout(),
    expect: () => const [
      LogoutInProgress(),
      LogoutFailure('No internet connection.'),
    ],
  );

  blocTest<LogoutCubit, LogoutState>(
    'emits [LogoutInProgress, LogoutFailure] with a generic message on '
    'unknown errors',
    setUp: () {
      when(() => logout(any())).thenThrow(StateError('boom'));
    },
    build: () => LogoutCubit(logout),
    act: (cubit) => cubit.logout(),
    expect: () => const [
      LogoutInProgress(),
      LogoutFailure('Something went wrong.'),
    ],
  );
}
