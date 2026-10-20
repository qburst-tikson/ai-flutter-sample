import 'package:ai_flutter_sample/core/di/injection.dart';
import 'package:ai_flutter_sample/features/auth/data/repositories/in_memory_session_repository_impl.dart';
import 'package:ai_flutter_sample/features/auth/domain/repositories/session_repository.dart';
import 'package:ai_flutter_sample/features/auth/domain/usecases/logout.dart';
import 'package:ai_flutter_sample/features/auth/presentation/cubit/login_cubit.dart';
import 'package:ai_flutter_sample/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:ai_flutter_sample/features/auth/presentation/pages/login_page.dart';
import 'package:ai_flutter_sample/features/home/domain/entities/greeting.dart';
import 'package:ai_flutter_sample/features/home/presentation/cubit/home_cubit.dart';
import 'package:ai_flutter_sample/features/home/presentation/pages/home_page.dart';
import 'package:ai_flutter_sample/features/main_shell/presentation/cubit/main_shell_cubit.dart';
import 'package:ai_flutter_sample/features/main_shell/presentation/pages/main_shell_page.dart';
import 'package:ai_flutter_sample/features/search/presentation/pages/search_page.dart';
import 'package:ai_flutter_sample/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:ai_flutter_sample/features/settings/presentation/pages/settings_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

void main() {
  late _MockHomeCubit homeCubit;
  late _MockSettingsCubit settingsCubit;

  setUp(() {
    homeCubit = _MockHomeCubit();
    when(() => homeCubit.state).thenReturn(
      const HomeLoaded(Greeting(title: 'Hi', message: 'Hello there')),
    );
    when(() => homeCubit.load()).thenAnswer((_) async {});
    sl.registerFactory<HomeCubit>(() => homeCubit);
    sl.registerFactory<MainShellCubit>(MainShellCubit.new);
    // SettingsPage resolves its cubit from sl; the tests here only check
    // navigation, so a static not-logged-in state is enough.
    settingsCubit = _MockSettingsCubit();
    when(() => settingsCubit.state).thenReturn(const SettingsNotLoggedIn());
    sl.registerFactory<SettingsCubit>(() => settingsCubit);
    // LogoutButton resolves LogoutCubit from sl; use the real cubit with
    // the real use case and a real in-memory session.
    sl.registerLazySingleton<SessionRepository>(
      () => InMemorySessionRepositoryImpl(),
    );
    sl.registerLazySingleton(() => Logout(sl()));
    sl.registerFactory(() => LogoutCubit(sl()));
  });

  tearDown(() async {
    await sl.reset();
  });

  Future<void> pumpShell(WidgetTester tester) =>
      tester.pumpWidget(const MaterialApp(home: MainShellPage()));

  Future<void> swipe(WidgetTester tester, Offset offset) async {
    await tester.drag(find.byType(PageView), offset);
    await tester.pumpAndSettle();
  }

  testWidgets('shows the three tabs in order with their icons', (tester) async {
    await pumpShell(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(
          of: find.byType(NavigationBar), matching: find.text('Home')),
      findsOneWidget,
    );
    expect(
      find.descendant(
          of: find.byType(NavigationBar), matching: find.text('Search')),
      findsOneWidget,
    );
    expect(
      find.descendant(
          of: find.byType(NavigationBar), matching: find.text('Settings')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.byIcon(Icons.settings), findsNothing);
  });

  testWidgets('shows the Home tab by default', (tester) async {
    await pumpShell(tester);

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byType(SearchView), findsNothing);
    expect(find.byType(SettingsView), findsNothing);
  });

  testWidgets('tapping Search shows the Search screen and highlights the tab', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchView), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home), findsNothing);
    expect(find.byType(HomeView), findsNothing);
  });

  testWidgets(
    'tapping Settings shows the Settings screen and highlights the tab',
    (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsView), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);
      expect(find.byType(HomeView), findsNothing);
    },
  );

  testWidgets('swiping left moves to Search and highlights its tab', (
    tester,
  ) async {
    await pumpShell(tester);

    await swipe(tester, const Offset(-500, 0));

    expect(find.byType(SearchView), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home), findsNothing);
  });

  testWidgets('swiping right from Search moves back to Home', (tester) async {
    await pumpShell(tester);

    await swipe(tester, const Offset(-500, 0));
    await swipe(tester, const Offset(500, 0));

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);
  });

  testWidgets('swiping left twice reaches Settings', (tester) async {
    await pumpShell(tester);

    await swipe(tester, const Offset(-500, 0));
    await swipe(tester, const Offset(-500, 0));

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home), findsNothing);
  });

  testWidgets('swiping right on Home stays clamped on Home', (tester) async {
    await pumpShell(tester);

    await swipe(tester, const Offset(500, 0));

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);
  });

  testWidgets('swiping left on Settings stays clamped on Settings', (
    tester,
  ) async {
    await pumpShell(tester);
    await swipe(tester, const Offset(-500, 0));
    await swipe(tester, const Offset(-500, 0));

    await swipe(tester, const Offset(-500, 0));

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.byType(HomeView), findsNothing);
  });

  testWidgets('shows the logout button on the Search and Settings tabs', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.logout), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('logout from the Home tab returns to Login and clears the stack',
      (
    tester,
  ) async {
    final loginCubit = _MockLoginCubit();
    when(() => loginCubit.state).thenReturn(const LoginInitial());
    sl.registerFactory<LoginCubit>(() => loginCubit);

    await pumpShell(tester);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(MainShellView), findsNothing);
    expect(find.byType(HomeView), findsNothing);
    final navigator = find.byType(Navigator).first;
    expect(
      tester.state<NavigatorState>(navigator).canPop(),
      isFalse,
      reason: 'the navigation stack should be cleared after logging out',
    );
  });

  testWidgets(
    'logout from the Settings tab returns to Login and clears the stack',
    (tester) async {
      final loginCubit = _MockLoginCubit();
      when(() => loginCubit.state).thenReturn(const LoginInitial());
      sl.registerFactory<LoginCubit>(() => loginCubit);

      await pumpShell(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(MainShellView), findsNothing);
      expect(find.byType(SettingsView), findsNothing);
      final navigator = find.byType(Navigator).first;
      expect(
        tester.state<NavigatorState>(navigator).canPop(),
        isFalse,
        reason: 'the navigation stack should be cleared after logging out',
      );
    },
  );
}
