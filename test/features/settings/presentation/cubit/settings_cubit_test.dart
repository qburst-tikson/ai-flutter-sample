import 'package:ai_flutter_sample/features/auth/domain/entities/user.dart';
import 'package:ai_flutter_sample/features/auth/domain/repositories/session_repository.dart';
import 'package:ai_flutter_sample/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late _MockSessionRepository sessionRepository;

  setUp(() {
    sessionRepository = _MockSessionRepository();
  });

  SettingsCubit buildCubit() => SettingsCubit(sessionRepository);

  test('initial state is SettingsInitial', () {
    expect(buildCubit().state, const SettingsInitial());
  });

  blocTest<SettingsCubit, SettingsState>(
    'emits SettingsLoaded with the email when a user is logged in',
    setUp: () {
      when(() => sessionRepository.currentUser)
          .thenReturn(const User(email: 'tikson@qburst.com'));
    },
    build: buildCubit,
    act: (cubit) => cubit.loadCurrentUser(),
    expect: () => const [SettingsLoaded('tikson@qburst.com')],
  );

  blocTest<SettingsCubit, SettingsState>(
    'emits SettingsNotLoggedIn when there is no user',
    setUp: () {
      when(() => sessionRepository.currentUser).thenReturn(null);
    },
    build: buildCubit,
    act: (cubit) => cubit.loadCurrentUser(),
    expect: () => const [SettingsNotLoggedIn()],
  );
}
