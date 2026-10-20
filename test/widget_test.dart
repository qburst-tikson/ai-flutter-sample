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
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

void main() {
  late _MockHomeCubit cubit;

  setUp(() {
    cubit = _MockHomeCubit();
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

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<HomeCubit>.value(
        value: cubit,
        child: const HomeView(),
      ),
    );
  }

  testWidgets('shows a spinner while loading', (tester) async {
    when(() => cubit.state).thenReturn(const HomeLoading());

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the greeting when loaded', (tester) async {
    when(() => cubit.state).thenReturn(
      const HomeLoaded(Greeting(title: 'Hi', message: 'Hello there')),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('Hi'), findsOneWidget);
    expect(find.text('Hello there'), findsOneWidget);
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    when(() => cubit.state).thenReturn(const HomeError('Oops'));
    when(() => cubit.load()).thenAnswer((_) async {});

    await tester.pumpWidget(buildSubject());
    expect(find.text('Oops'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => cubit.load()).called(1);
  });

  testWidgets('shows the logout button in the AppBar when loaded', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      const HomeLoaded(Greeting(title: 'Hi', message: 'Hello there')),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('shows the confirm dialog when the logout button is tapped', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      const HomeLoaded(Greeting(title: 'Hi', message: 'Hello there')),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Logout?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('stays on Home when Cancel is tapped', (tester) async {
    when(() => cubit.state).thenReturn(
      const HomeLoaded(Greeting(title: 'Hi', message: 'Hello there')),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Logout?'), findsNothing);
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
  });

  testWidgets('navigates to Login and clears the stack on confirm', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      const HomeLoaded(Greeting(title: 'Hi', message: 'Hello there')),
    );
    final loginCubit = _MockLoginCubit();
    when(() => loginCubit.state).thenReturn(const LoginInitial());
    sl.registerFactory<LoginCubit>(() => loginCubit);

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(HomeView), findsNothing);
    final navigator = find.byType(Navigator).first;
    expect(
      tester.state<NavigatorState>(navigator).canPop(),
      isFalse,
      reason: 'the navigation stack should be cleared after logging out',
    );
  });
}
