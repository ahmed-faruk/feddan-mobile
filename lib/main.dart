import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'config/di/injection.dart';
import 'presentation/blocs/language/language_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('settings');

  setupDependencies();

  runApp(
    BlocProvider(
      create: (_) => getIt<LanguageBloc>(),
      child: const FeddanApp(),
    ),
  );
}
