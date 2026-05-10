import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'config/di/injection.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/language/language_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Notification service must be initialized before runApp so the
  // background message handler is registered at startup.
  await NotificationService.initialize();

  await Hive.initFlutter();
  await Hive.openBox('settings');

  setupDependencies();

  // For returning users who are already authenticated, request/refresh
  // the FCM token without blocking the UI.
  if (FirebaseAuth.instance.currentUser != null) {
    NotificationService.requestPermission();
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LanguageBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
      ],
      child: const FeddanApp(),
    ),
  );
}
