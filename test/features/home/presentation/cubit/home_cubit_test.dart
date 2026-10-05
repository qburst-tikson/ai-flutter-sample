import 'package:ai_flutter_sample/core/error/failure.dart';
import 'package:ai_flutter_sample/core/usecase/usecase.dart';
import 'package:ai_flutter_sample/features/home/domain/entities/greeting.dart';
import 'package:ai_flutter_sample/features/home/domain/usecases/get_greeting.dart';
import 'package:ai_flutter_sample/features/home/presentation/cubit/home_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetGreeting extends Mock implements GetGreeting {}

void main() {
  late _MockGetGreeting getGreeting;

  const greeting = Greeting(title: 'Hi', message: 'Hello there');

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getGreeting = _MockGetGreeting();
  });

  test('initial state is HomeInitial', () {
    expect(HomeCubit(getGreeting).state, const HomeInitial());
  });

  blocTest<HomeCubit, HomeState>(
    'emits [Loading, Loaded] when the greeting loads',
    setUp: () {
      when(() => getGreeting(any())).thenAnswer((_) async => greeting);
    },
    build: () => HomeCubit(getGreeting),
    act: (cubit) => cubit.load(),
    expect: () => const [HomeLoading(), HomeLoaded(greeting)],
  );

  blocTest<HomeCubit, HomeState>(
    'emits [Loading, Error] with the failure message on Failure',
    setUp: () {
      when(() => getGreeting(any())).thenThrow(const NetworkFailure());
    },
    build: () => HomeCubit(getGreeting),
    act: (cubit) => cubit.load(),
    expect: () => const [
      HomeLoading(),
      HomeError('No internet connection.'),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'emits [Loading, Error] with a generic message on unknown errors',
    setUp: () {
      when(() => getGreeting(any())).thenThrow(StateError('boom'));
    },
    build: () => HomeCubit(getGreeting),
    act: (cubit) => cubit.load(),
    expect: () => const [
      HomeLoading(),
      HomeError('Something went wrong.'),
    ],
  );
}
