# Feddan — Claude Code Context

## Project
Flutter mobile app for farmers in Egypt and the Middle East. Provides automated, location-aware task management based on weather data and crop growth stages.

## Mission
Pre-Seed MVP to demonstrate value and raise funds. Arabic-first UI, optimized for rural users on slow connections.

## Supported Crops
Tomatoes, potatoes, eggplant, peppers, watermelon, cantaloupe, honeydew, cucumber, squash, zucchini.

## Stack
- **Frontend:** Flutter (Android-first for MVP, Arabic RTL default)
- **Auth:** Firebase Auth (phone OTP + Google Sign-In)
- **Database:** Cloud Firestore
- **Functions:** Firebase Cloud Functions (Node.js, scheduled via Cloud Scheduler)
- **Notifications:** Firebase Cloud Messaging (FCM)
- **Weather:** NASA POWER API (free, no key) for scheduled tasks; OpenWeatherMap free tier for alerts
- **Maps:** Google Maps Flutter plugin (farm location pin)

## Budget Constraint
Total $100 for first 6 months. No paid APIs. NASA POWER is primary weather source.

## Key Architecture Rules
- Weather is fetched server-side once per farm per day, cached in Firestore. Flutter never calls weather APIs directly.
- Task engine runs daily at 6am Cairo time (Africa/Cairo timezone) via Cloud Scheduler.
- Firestore reads are minimized via denormalized task documents — one read per farm dashboard load.
- Offline support: cache last task list locally with `hive`.

## Agronomy Reference
Crop water demand: ETc = ET0 × Kc (FAO-56 standard). Kc values are hardcoded lookup tables per crop and growth stage. No paid agronomic API.

## Languages
- Arabic (default, RTL) — all user-facing strings in `ar` locale
- English (toggle) — `en` locale
- Use Flutter's `intl` + `flutter_localizations` packages.

## Code Conventions
- State management: Riverpod
- Navigation: GoRouter
- Local storage: Hive
- HTTP (Cloud Functions internal): `dio`
- All monetary/unit values: metric (mm for water, °C for temperature, hectares for area)
