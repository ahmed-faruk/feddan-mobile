import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/farm_remote_datasource.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/farm_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_farm_usecase.dart';
import '../../domain/usecases/get_farms_usecase.dart';
import '../../domain/usecases/get_today_tasks_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/farm/farm_bloc.dart';
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

  // ── Repositories ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton<FarmRepositoryImpl>(
      () => FarmRepositoryImpl(getIt()));
  getIt.registerLazySingleton<TaskRepositoryImpl>(
      () => TaskRepositoryImpl(getIt()));

  // ── Use cases ─────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<CreateFarmUseCase>(
      () => CreateFarmUseCase(getIt<FarmRepositoryImpl>()));
  getIt.registerLazySingleton<GetFarmsUseCase>(
      () => GetFarmsUseCase(getIt<FarmRepositoryImpl>()));
  getIt.registerLazySingleton<GetTodayTasksUseCase>(
      () => GetTodayTasksUseCase(getIt<TaskRepositoryImpl>()));
  getIt.registerLazySingleton<CompleteTaskUseCase>(
      () => CompleteTaskUseCase(getIt<TaskRepositoryImpl>()));

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<LanguageBloc>(() => LanguageBloc());
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(repository: getIt()));

  getIt.registerFactory<FarmListCubit>(
    () => FarmListCubit(getFarms: getIt(), auth: getIt()),
  );
  getIt.registerFactory<FarmBloc>(() => FarmBloc(createFarm: getIt()));
  getIt.registerFactory<TaskBloc>(
    () => TaskBloc(getTodayTasks: getIt(), completeTask: getIt()),
  );
}
