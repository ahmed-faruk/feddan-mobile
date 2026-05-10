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
- **Auth:** Firebase Auth (phone OTP + Google Sign-In)
- **Database:** Cloud Firestore
- **Functions:** Firebase Cloud Functions (Node.js, scheduled via Cloud Scheduler)
- **Notifications:** Firebase Cloud Messaging (FCM)
- **Weather:** NASA POWER API (free, no key) for scheduled tasks; OpenWeatherMap free tier for alerts
- **Maps:** google_maps_flutter (farm location pin)
- **Navigation:** GoRouter
- **Local Storage:** Hive (offline cache + settings persistence)
- **DI:** GetIt service locator
- **HTTP:** Dio (used only in Cloud Functions, not Flutter client)
- **Code Gen:** freezed + json_serializable + build_runner

## Localization
- **Default language: Arabic (ar)** — RTL, all UI defaults to Arabic
- **Secondary language: English (en)** — user can toggle in-app; preference persisted in Hive
- Uses Flutter gen-l10n (`flutter generate: true` in pubspec.yaml, `l10n.yaml` at root)
- ARB files in `lib/l10n/` — `app_ar.arb` is the template (source of truth)
- Import generated localizations as: `package:flutter_gen/gen_l10n/app_localizations.dart`
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
│   ├── errors/                # Failure classes (NetworkFailure, CacheFailure, etc.)
│   └── theme/                 # AppTheme, AppColors
├── config/
│   ├── router/                # GoRouter definition (AppRouter)
│   └── di/                    # GetIt injection setup (injection.dart)
├── data/
│   ├── datasources/
│   │   ├── local/             # Hive data sources
│   │   └── remote/            # Firestore + API data sources
│   ├── models/                # Data models (with freezed + json_serializable)
│   └── repositories/          # Repository implementations
├── domain/
│   ├── entities/              # Pure domain entities (no JSON, no Hive)
│   ├── repositories/          # Abstract repository interfaces
│   └── usecases/              # Single-responsibility use cases
└── presentation/
    ├── blocs/                  # BLoC files (bloc, event, state per feature)
    │   └── language/           # LanguageBloc — locale switching
    ├── pages/                  # One folder per route/screen
    │   ├── splash/
    │   └── home/
    └── widgets/
        └── common/             # Shared UI components
```

## BLoC Conventions
- Each feature has its own subfolder: `blocs/<feature>/`
- Three files per BLoC: `<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`
- States and Events extend Equatable
- Use `Bloc` for complex logic, `Cubit` for simple state toggling
- BlocProviders are registered in `main.dart` or feature-level wrappers

## Budget Constraint
Total $100 for first 6 months. No paid APIs. NASA POWER is primary weather source (free, unlimited, no API key required).

## Key Architecture Rules
- Weather is fetched server-side once per farm per day, cached in Firestore. Flutter never calls weather APIs directly.
- Task engine runs daily at 6am Cairo time (Africa/Cairo) via Cloud Scheduler.
- Firestore reads minimized via denormalized task documents — one read per farm dashboard load.
- Offline: last task list cached with Hive.

## Agronomy Reference
Crop water demand: ETc = ET0 × Kc (FAO-56 standard). Kc values are hardcoded lookup tables per crop and growth stage. No paid agronomic API.

## Code Conventions
- All monetary/unit values: metric (mm for water, °C for temperature, hectares for area)
- Large tap targets: minimum 52px height for all interactive elements (rural UX)
- RTL-safe layouts: use `start`/`end` instead of `left`/`right`
- No comments unless WHY is non-obvious
