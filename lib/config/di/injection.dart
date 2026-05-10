import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/remote/farm_remote_datasource.dart';
import '../../data/repositories/farm_repository_impl.dart';
import '../../domain/usecases/create_farm_usecase.dart';
import '../../presentation/blocs/farm/farm_bloc.dart';
import '../../presentation/blocs/language/language_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // External
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Data sources
  getIt.registerLazySingleton<FarmRemoteDataSource>(
    () => FarmRemoteDataSource(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<FarmRepositoryImpl>(
    () => FarmRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton<CreateFarmUseCase>(
    () => CreateFarmUseCase(getIt<FarmRepositoryImpl>()),
  );

  // BLoCs — LanguageBloc is a singleton (app-level), FarmBloc is a factory (per screen)
  getIt.registerLazySingleton<LanguageBloc>(() => LanguageBloc());
  getIt.registerFactory<FarmBloc>(
    () => FarmBloc(createFarm: getIt()),
  );
}
