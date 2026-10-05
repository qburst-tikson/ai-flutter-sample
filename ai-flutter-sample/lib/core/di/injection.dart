import 'package:get_it/get_it.dart';

import '../../features/home/data/repositories/greeting_repository_impl.dart';
import '../../features/home/domain/repositories/greeting_repository.dart';
import '../../features/home/domain/usecases/get_greeting.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Registers every dependency. Call once in `main()` before `runApp`.
///
/// Convention per feature:
///   - repositories & data sources → registerLazySingleton
///   - use cases                   → registerLazySingleton
///   - blocs / cubits              → registerFactory (new instance per screen)
Future<void> configureDependencies() async {
  // ── Home ──────────────────────────────────────────────
  sl
    ..registerLazySingleton<GreetingRepository>(
      () => const GreetingRepositoryImpl(),
    )
    ..registerLazySingleton(() => GetGreeting(sl()))
    ..registerFactory(() => HomeCubit(sl()));
}
