import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/farm_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/farm_repository_impl.dart';
import '../../domain/usecases/create_farm_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/farm/farm_bloc.dart';
import '../../presentation/blocs/language/language_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // External services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<FarmRemoteDataSource>(
    () => FarmRemoteDataSource(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<FarmRepositoryImpl>(
    () => FarmRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton<CreateFarmUseCase>(
    () => CreateFarmUseCase(getIt<FarmRepositoryImpl>()),
  );

  // BLoCs
  // Singletons: app-level blocs shared across the whole widget tree
  getIt.registerLazySingleton<LanguageBloc>(() => LanguageBloc());
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(repository: getIt()),
  );
  // Factories: per-screen blocs created fresh for each page
  getIt.registerFactory<FarmBloc>(
    () => FarmBloc(createFarm: getIt()),
  );
}
