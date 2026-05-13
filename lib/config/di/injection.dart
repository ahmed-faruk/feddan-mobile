import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/local/farm_local_datasource.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/farm_remote_datasource.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/farm_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/farm_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_farm_usecase.dart';
import '../../domain/usecases/delete_farm_usecase.dart';
import '../../domain/usecases/get_cached_farms_usecase.dart';
import '../../domain/usecases/get_farms_usecase.dart';
import '../../domain/usecases/get_today_tasks_usecase.dart';
import '../../domain/usecases/update_farm_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/farm_list/farm_list_cubit.dart';
import '../../presentation/blocs/language/language_bloc.dart';
import '../../presentation/blocs/task/task_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // ── External services ────────────────────────────────────────────────────
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  // ── Data sources ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt()));
  getIt.registerLazySingleton<FarmRemoteDataSource>(
      () => FarmRemoteDataSource(getIt()));
  getIt.registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSource(getIt()));
  getIt.registerLazySingleton<FarmLocalDataSource>(
      () => FarmLocalDataSource());
  getIt.registerLazySingleton<TaskLocalDataSource>(
      () => TaskLocalDataSource());

  // ── Repositories — registered under their abstract interface ─────────────
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton<FarmRepository>(
      () => FarmRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(getIt(), getIt()));

  // ── Use cases ─────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<CreateFarmUseCase>(
      () => CreateFarmUseCase(getIt<FarmRepository>()));
  getIt.registerLazySingleton<UpdateFarmUseCase>(
      () => UpdateFarmUseCase(getIt<FarmRepository>()));
  getIt.registerLazySingleton<DeleteFarmUseCase>(
      () => DeleteFarmUseCase(getIt<FarmRepository>()));
  getIt.registerLazySingleton<GetFarmsUseCase>(
      () => GetFarmsUseCase(getIt<FarmRepository>()));
  getIt.registerLazySingleton<GetCachedFarmsUseCase>(
      () => GetCachedFarmsUseCase(getIt<FarmRepository>()));
  getIt.registerLazySingleton<GetTodayTasksUseCase>(
      () => GetTodayTasksUseCase(getIt<TaskRepository>()));
  getIt.registerLazySingleton<CompleteTaskUseCase>(
      () => CompleteTaskUseCase(getIt<TaskRepository>()));

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  // Singletons: app-level, shared across the widget tree
  getIt.registerLazySingleton<LanguageBloc>(() => LanguageBloc());
  getIt.registerLazySingleton<AuthBloc>(
      () => AuthBloc(repository: getIt<AuthRepository>()));

  // Factories: created fresh per screen instance
  getIt.registerFactory<FarmListCubit>(
    () => FarmListCubit(
      getFarms: getIt(),
      getCachedFarms: getIt(),
      auth: getIt<AuthRepository>(),
    ),
  );
  // FarmBloc is not registered here — it's constructed directly in
  // FarmProfilePage so it can receive an optional existingFarm argument.
  getIt.registerFactory<TaskBloc>(
    () => TaskBloc(getTodayTasks: getIt(), completeTask: getIt()),
  );
}
