import 'package:ai_flutter_sample/features/main_shell/presentation/cubit/main_shell_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial state is MainShellInitial with tab index 0', () {
    final cubit = MainShellCubit();

    expect(cubit.state, const MainShellInitial());
    expect(cubit.index, 0);
  });

  blocTest<MainShellCubit, MainShellState>(
    'emits [TabChanged(1)] when changeTab(1) is called',
    build: MainShellCubit.new,
    act: (cubit) => cubit.changeTab(1),
    expect: () => const [MainShellTabChanged(1)],
  );

  blocTest<MainShellCubit, MainShellState>(
    'emits nothing when the current index is set again',
    build: () {
      final cubit = MainShellCubit();
      cubit.changeTab(2);
      return cubit;
    },
    act: (cubit) => cubit.changeTab(2),
    expect: () => <MainShellState>[],
  );

  blocTest<MainShellCubit, MainShellState>(
    'emits nothing when the initial index (0) is set again',
    build: MainShellCubit.new,
    act: (cubit) => cubit.changeTab(0),
    expect: () => <MainShellState>[],
  );
}
