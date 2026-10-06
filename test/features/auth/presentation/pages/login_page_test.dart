import 'package:ai_flutter_sample/core/di/injection.dart';
import 'package:ai_flutter_sample/features/auth/presentation/cubit/login_cubit.dart';
import 'package:ai_flutter_sample/features/auth/presentation/pages/login_page.dart';
import 'package:ai_flutter_sample/features/home/presentation/cubit/home_cubit.dart';
import 'package:ai_flutter_sample/features/home/presentation/pages/home_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late _MockLoginCubit cubit;

  setUp(() {
    cubit = _MockLoginCubit();
    when(() => cubit.login(any(), any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await sl.reset();
  });

  Future<void> pumpView(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginCubit>.value(
          value: cubit,
          child: const LoginView(),
        ),
      ),
    );
  }

  testWidgets('shows the fields and the login button initially', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const LoginInitial());

    await pumpView(tester);

    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows inline errors under the matching fields', (tester) async {
    when(() => cubit.state).thenReturn(
      const LoginInvalid(
        emailError: 'Enter a valid email address',
        passwordError: 'Password must be at least 6 characters',
      ),
    );

    await pumpView(tester);

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(
      find.text('Password must be at least 6 characters'),
      findsOneWidget,
    );
  });

  testWidgets('shows a spinner and disables the button while loading', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const LoginLoading());

    await pumpView(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows a snackbar on error', (tester) async {
    whenListen(
      cubit,
      Stream<LoginState>.value(const LoginError('No internet connection.')),
      initialState: const LoginInitial(),
    );

    await pumpView(tester);
    await tester.pump();

    expect(find.text('No internet connection.'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('tapping Login calls cubit.login with the entered values', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const LoginInitial());

    await pumpView(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'secret1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));

    verify(() => cubit.login('user@example.com', 'secret1')).called(1);
  });

  testWidgets('editing a field asks the cubit to clear its error', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const LoginInitial());

    await pumpView(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'a');

    verify(() => cubit.clearFieldError(email: true)).called(1);
  });

  testWidgets('navigates to the home page on success', (tester) async {
    final homeCubit = _MockHomeCubit();
    when(() => homeCubit.state).thenReturn(const HomeLoading());
    when(() => homeCubit.load()).thenAnswer((_) async {});
    sl.registerFactory<HomeCubit>(() => homeCubit);
    whenListen(
      cubit,
      Stream<LoginState>.value(const LoginSuccess()),
      initialState: const LoginInitial(),
    );

    await pumpView(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
  });
}
