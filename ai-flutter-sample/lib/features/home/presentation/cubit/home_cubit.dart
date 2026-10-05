import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/greeting.dart';
import '../../domain/usecases/get_greeting.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getGreeting) : super(const HomeInitial());

  final GetGreeting _getGreeting;

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final greeting = await _getGreeting(const NoParams());
      emit(HomeLoaded(greeting));
    } on Failure catch (failure) {
      emit(HomeError(failure.message));
    } catch (_) {
      emit(const HomeError('Something went wrong.'));
    }
  }
}
