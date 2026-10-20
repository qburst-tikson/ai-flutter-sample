import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/fake_auth_repository_impl.dart';
import '../../features/auth/data/repositories/in_memory_session_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/session_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/logout_cubit.dart';
import '../../features/home/data/repositories/greeting_repository_impl.dart';
import '../../features/home/domain/repositories/greeting_repository.dart';
import '../../features/home/domain/usecases/get_greeting.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/main_shell/presentation/cubit/main_shell_cubit.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

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

  // ── MainShell ─────────────────────────────────────────
  sl.registerFactory(() => MainShellCubit());

  // ── Settings ──────────────────────────────────────────
  sl.registerFactory(() => SettingsCubit(sl()));

  // ── Auth ──────────────────────────────────────────────
  sl
    ..registerLazySingleton<AuthRepository>(
      () => const FakeAuthRepositoryImpl(),
    )
    ..registerLazySingleton<SessionRepository>(
      () => InMemorySessionRepositoryImpl(),
    )
    ..registerLazySingleton(() => Login(sl()))
    ..registerLazySingleton(() => Logout(sl()))
    ..registerFactory(() => LoginCubit(sl(), sl()))
    ..registerFactory(() => LogoutCubit(sl()));
}
