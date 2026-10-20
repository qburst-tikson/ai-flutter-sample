import 'package:ai_flutter_sample/core/di/injection.dart';
import 'package:ai_flutter_sample/features/auth/data/demo_credentials.dart';
import 'package:ai_flutter_sample/features/auth/data/repositories/in_memory_session_repository_impl.dart';
import 'package:ai_flutter_sample/features/auth/domain/repositories/session_repository.dart';
import 'package:ai_flutter_sample/features/auth/domain/usecases/logout.dart';
import 'package:ai_flutter_sample/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:ai_flutter_sample/features/auth/presentation/pages/login_page.dart';
import 'package:ai_flutter_sample/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:ai_flutter_sample/features/settings/presentation/pages/settings_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

void main() {
  late _MockSettingsCubit cubit;

  setUp(() {
    cubit = _MockSettingsCubit();
    // The app bar builds LogoutButton, which resolves LogoutCubit from sl;
    // these tests never tap it, so the real cubit with the real use case
    // and a real in-memory session is fine.
    sl.registerLazySingleton<SessionRepository>(
      () => InMemorySessionRepositoryImpl(),
    );
    sl.registerLazySingleton(() => Logout(sl()));
    sl.registerFactory(() => LogoutCubit(sl()));
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<SettingsCubit>.value(
        value: cubit,
        child: const SettingsView(),
      ),
    );
  }

  testWidgets('shows "Logged in as" with the email when loaded', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const SettingsLoaded('a@b.com'));

    await tester.pumpWidget(buildSubject());

    expect(find.text('Logged in as'), findsOneWidget);
    expect(find.text('a@b.com'), findsOneWidget);
  });

  testWidgets('shows "Not logged in" when there is no user', (tester) async {
    when(() => cubit.state).thenReturn(const SettingsNotLoggedIn());

    await tester.pumpWidget(buildSubject());

    expect(find.text('Not logged in'), findsOneWidget);
    expect(find.text('Logged in as'), findsNothing);
  });

  testWidgets('keeps the "Settings" app bar title and the logout action', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const SettingsLoaded('a@b.com'));

    await tester.pumpWidget(buildSubject());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets(
    'logout then login with the demo account shows the email again',
    (tester) async {
      // Real end-to-end flow: real DI, real session, fake auth repository,
      // no sl mocking. Reset first: setUp already registered the logout
      // dependencies, and configureDependencies registers them again.
      await sl.reset();
      await configureDependencies();
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      Future<void> loginWithDemoAccount() async {
        await tester.enterText(
          find.widgetWithText(TextField, 'Email'),
          DemoCredentials.email,
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Password'),
          DemoCredentials.password,
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Login'));
        // The fake repository answers after one second.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
      }

      await loginWithDemoAccount();
      expect(find.text('Logged in as'), findsOneWidget);
      expect(find.text(DemoCredentials.email), findsOneWidget);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);

      await loginWithDemoAccount();
      expect(find.text('Logged in as'), findsOneWidget);
      expect(find.text(DemoCredentials.email), findsOneWidget);
    },
  );
}
