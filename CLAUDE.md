# Feddan — Claude Code Context

## Project
Flutter mobile app for farmers in Egypt and the Middle East. Provides automated, location-aware task management based on weather data and crop growth stages.

## Mission
Pre-Seed MVP to demonstrate value and raise funds. Arabic-first UI, optimized for rural users on slow connections.

## Supported Crops
Tomatoes, potatoes, eggplant, peppers, watermelon, cantaloupe, honeydew, cucumber, squash, zucchini.

## Platforms
Android and iOS (both supported from day one).

## Stack
- **Frontend:** Flutter 3.x — Android + iOS
- **State Management:** flutter_bloc (BLoC pattern) — all features use Bloc/Cubit
- **Auth:** Firebase Auth — phone OTP + Google Sign-In
- **Database:** Cloud Firestore
- **Functions:** Firebase Cloud Functions (Node.js 22, scheduled via Cloud Scheduler)
- **Notifications:** Firebase Cloud Messaging (FCM)
- **Weather:** NASA POWER API (free, no key) for scheduled tasks; OpenWeatherMap free tier for real-time alerts
- **Maps:** google_maps_flutter (farm location pin, draggable marker)
- **Navigation:** GoRouter
- **Local Storage:** Hive (offline task cache + settings persistence)
- **DI:** GetIt service locator
- **HTTP:** Dio used only in Cloud Functions (Node.js); Flutter client makes no direct HTTP calls

## Localization
- **Default language: Arabic (ar)** — RTL, all UI defaults to Arabic
- **Secondary language: English (en)** — user can toggle in-app; preference persisted in Hive
- Uses Flutter gen-l10n (`flutter generate: true` in pubspec.yaml, `l10n.yaml` at root)
- ARB files in `lib/l10n/` — `app_ar.arb` is the template (source of truth)
- Import generated localizations as: `package:feddan/l10n/app_localizations.dart`
- After adding/changing strings: run `flutter gen-l10n`

## BLoC Architecture (Clean Architecture layers)
```
lib/
├── main.dart                  # Entry: Hive init, DI setup, BlocProviders
├── app.dart                   # MaterialApp.router, locale + theme BlocBuilders
├── l10n/                      # ARB translation files
│   ├── app_ar.arb             # Arabic (template/default)
│   └── app_en.arb             # English
├── core/
│   ├── constants/             # App-wide constants (crop types, settings keys)
│   ├── errors/                # Failure classes (NetworkFailure, ServerFailure, AuthFailure)
│   └── theme/                 # AppTheme, AppColors
├── config/
│   ├── router/                # GoRouter definition (AppRouter) — 5 routes
│   └── di/                    # GetIt injection setup (injection.dart)
├── data/
│   ├── datasources/
│   │   ├── local/             # Hive data sources (TaskLocalDataSource)
│   │   └── remote/            # Firestore + API data sources
│   ├── models/                # Data models (FarmModel, TaskModel — manual JSON)
│   └── repositories/          # Repository implementations
├── domain/
│   ├── entities/              # Pure domain entities (FarmEntity, TaskEntity, WeatherSnapshot)
│   ├── repositories/          # Abstract repository interfaces
│   └── usecases/              # Single-responsibility use cases
└── presentation/
    ├── blocs/                  # BLoC files (bloc, event, state per feature)
    │   └── language/           # LanguageBloc — locale switching
    ├── pages/                  # One folder per route/screen
    │   ├── splash/
    │   ├── auth/
    │   ├── home/
    │   ├── farm_profile/
    │   └── settings/
    └── widgets/
        └── common/             # Shared UI components
```

## Routes
- `/` → SplashPage (auth check)
- `/auth` → AuthPage (phone OTP + Google Sign-In)
- `/home` → HomePage (farm chips, weather card, task list)
- `/farm-profile` → FarmProfilePage (create or edit; pass `FarmEntity` as GoRouter `extra` for edit)
- `/settings` → SettingsPage (language selector)

## BLoC Conventions
- Each feature has its own subfolder: `blocs/<feature>/`
- Three files per BLoC: `<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`
- States and Events extend Equatable
- Use `Bloc` for complex logic, `Cubit` for simple state toggling
- BlocProviders are registered in `main.dart` or feature-level wrappers
- FarmBloc is NOT registered in GetIt — it's constructed directly in FarmProfilePage (needs optional `existingFarm` arg)

## Budget Constraint
Total $100 for first 6 months. No paid APIs except Google Maps. NASA POWER is primary weather source (free, unlimited, no API key required). OWM free tier (1,000 calls/day) for real-time alerts.

## Key Architecture Rules
- Weather is fetched server-side once per farm per day, cached in Firestore (`latestWeather` field on farm doc). Flutter never calls weather APIs directly.
- Task engine runs daily at 6am Cairo time (Africa/Cairo) via Cloud Scheduler.
- Weather alert scanner runs every 6 hours via Cloud Scheduler (OWM).
- Firestore reads minimized via denormalized task documents — one read per farm dashboard load.
- Offline: last task list cached with Hive (Box<String> 'tasks_cache', keyed `{farmId}_{YYYYMMDD}`).

## Secrets (Firebase Functions)
- `ADMIN_SECRET` — guards the `runTaskEngineNow` HTTP endpoint
- `OWM_API_KEY` — OpenWeatherMap API key for weather alert scanner
Set via: `firebase functions:secrets:set SECRET_NAME --project feddan-mobile`

## Platform Setup Required (user actions)
- **Google Maps API key**: replace `YOUR_GOOGLE_MAPS_API_KEY` in:
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/AppDelegate.swift`
- **Google Sign-In iOS**: replace `YOUR_REVERSED_CLIENT_ID` in `ios/Runner/Info.plist` with the `REVERSED_CLIENT_ID` value from `ios/Runner/GoogleService-Info.plist`
- **Google Sign-In Android**: add SHA-1 + SHA-256 fingerprints to Firebase Console → Project Settings → Android app

## Agronomy Reference
Crop water demand: ETc = ET0 × Kc (FAO-56 standard). Kc values are hardcoded lookup tables per crop and growth stage. No paid agronomic API.

## Code Conventions
- All monetary/unit values: metric (mm for water, °C for temperature, hectares for area)
- Large tap targets: minimum 52px height for all interactive elements (rural UX)
- RTL-safe layouts: use `start`/`end` instead of `left`/`right`
- No comments unless WHY is non-obvious
