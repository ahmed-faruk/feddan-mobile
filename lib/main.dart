import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'config/di/injection.dart';
import 'core/services/notification_service.dart';
import 'data/datasources/local/farm_local_datasource.dart';
import 'data/datasources/local/task_local_datasource.dart';
import 'firebase_options.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/language/language_bloc.dart';

/// Returns the 32-byte AES key for the farms Hive box.
/// On first run a key is generated and stored in the OS keychain.
/// On subsequent runs the same key is retrieved.
Future<List<int>> _getFarmsCacheKey() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  const keyName = 'farms_cache_aes_key';
  final existing = await storage.read(key: keyName);
  if (existing != null) return base64Decode(existing);
  final key = Hive.generateSecureKey();
  await storage.write(key: keyName, value: base64Encode(key));
  return key;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // USE_EMULATOR is a compile-time flag set only for iOS Simulator runs:
  //   flutter run --dart-define=USE_EMULATOR=true
  // It is NEVER set for real-device builds or release builds, so production
  // phone auth uses real Firebase Auth → real SMS OTP as normal.
  // The emulator bypasses the iOS Simulator keychain restriction and needs
  // no Apple code-signing certificate.
  const useEmulator = bool.fromEnvironment('USE_EMULATOR');
  if (useEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  // Register the background message handler synchronously — this MUST happen
  // before runApp(). The rest of NotificationService.initialize() (foreground
  // options, local notifications, getInitialMessage) is non-critical for
  // startup and must NOT block runApp(); on iOS simulator getInitialMessage()
  // waits for an APNs token that never arrives, hanging the splash indefinitely.
  NotificationService.initialize(); // intentionally not awaited

  await Hive.initFlutter();
  await Hive.openBox('settings');
  // M-1: farms_cache is encrypted at rest — the AES key is stored in the OS
  // keychain (Android Keystore / iOS Secure Enclave) via flutter_secure_storage.
  final farmsCacheKey = await _getFarmsCacheKey();
  await Hive.openBox<String>(
    FarmLocalDataSource.boxName,
    encryptionCipher: HiveAesCipher(farmsCacheKey),
  );
  await Hive.openBox<String>(TaskLocalDataSource.boxName);

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
