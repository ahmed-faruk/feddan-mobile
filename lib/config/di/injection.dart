import 'package:get_it/get_it.dart';

import '../../presentation/blocs/language/language_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<LanguageBloc>(() => LanguageBloc());
}
