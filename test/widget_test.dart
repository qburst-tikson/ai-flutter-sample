import 'package:ai_flutter_sample/features/home/domain/entities/greeting.dart';
import 'package:ai_flutter_sample/features/home/presentation/cubit/home_cubit.dart';
import 'package:ai_flutter_sample/features/home/presentation/pages/home_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late _MockHomeCubit cubit;

  setUp(() {
    cubit = _MockHomeCubit();
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
}
