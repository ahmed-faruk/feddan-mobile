# فدان — Feddan

> Smart farm assistant for Egyptian and Middle Eastern farmers. Weather-aware daily task management, Arabic-first.

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20FCM-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Build in Public](https://img.shields.io/badge/building-in%20public-%232DA44E)](https://twitter.com/search?q=%23Feddan%20%23BuildInPublic)

---

## What is Feddan?

Feddan (فدان) is a pre-seed MVP mobile app that helps smallholder farmers in Egypt and the Middle East know **what to do in their fields today** — without needing agronomy expertise.

Every morning at 6am Cairo time, Feddan:
1. Fetches real weather data from [NASA POWER](https://power.larc.nasa.gov/) (free, no API key)
2. Calculates crop water demand using FAO-56 Kc coefficients
3. Generates personalised irrigation, fertilization, and disease-inspection tasks
4. Sends a push notification to the farmer's phone

The app speaks Arabic first (RTL), with an English toggle.

---

## Supported Crops

طماطم · بطاطس · باذنجان · فلفل · بطيخ · شمام · كنتالوب · خيار · كوسة · قرع

Tomato · Potato · Eggplant · Pepper · Watermelon · Cantaloupe · Honeydew · Cucumber · Squash · Zucchini

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x — Android + iOS |
| State | flutter_bloc (BLoC pattern) |
| Architecture | Clean Architecture (domain / data / presentation) |
| Auth | Firebase Auth — Phone OTP |
| Database | Cloud Firestore |
| Functions | Firebase Cloud Functions (TypeScript) |
| Notifications | Firebase Cloud Messaging + flutter_local_notifications |
| Weather | NASA POWER API (free, unlimited) |
| Location | geolocator |
| Navigation | GoRouter |
| Local storage | Hive |
| DI | GetIt |

**Total cost for 6 months:** under $100 (targeting ~$50).

---

## Architecture

```
lib/
├── core/               # Constants, theme, services (NotificationService)
├── config/             # GoRouter, GetIt DI
├── l10n/               # ARB files (ar + en), generated localisations
├── domain/             # Entities, repository interfaces, use cases
├── data/               # Models, Firestore data sources, repository impls
└── presentation/
    ├── blocs/          # BLoC: auth, language, farm, task
    └── pages/          # splash, auth, home, farm_profile

functions/
└── src/
    ├── index.ts        # Scheduled dailyTaskEngine + HTTP test trigger
    ├── taskEngine.ts   # Core logic: weather → crop demand → tasks
    ├── nasaPower.ts    # NASA POWER API client
    ├── cropConstants.ts# FAO-56 Kc values + stage durations
    └── notifications.ts# FCM daily digest sender
```

### Task Engine Formula

```
ETc (mm/day) = ET₀ × Kc

where:
  ET₀ = reference evapotranspiration from NASA POWER (mm/day)
  Kc  = FAO-56 crop coefficient for current growth stage

if ETc ≥ 3mm and rainfall < 3mm  → IRRIGATE task
if rainfall ≥ 3mm               → IRRIGATE_SKIP task
if humidity > 80% + 15–30°C    → INSPECT (fungal risk)
if stage transition day          → FERTILIZE task
```

---

## Getting Started

### Prerequisites

- Flutter 3.x
- Node.js 20+
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### Firebase setup

1. Create a Firebase project and run `flutterfire configure`
2. Enable **Phone Authentication** in Firebase Console
3. Create **Firestore Database** (region: me-central1)
4. Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`
5. For iOS push notifications, upload your APNs key in Firebase Console

### Running the app

```bash
flutter pub get
flutter gen-l10n
flutter run
```

### Deploying Cloud Functions

```bash
cd functions && npm install
firebase deploy --only functions --project=<your-project-id>
```

> Cloud Scheduler (required for the scheduled function) needs Firebase Blaze plan.

---

## Build in Public

This project is being built entirely in public. Follow the journey:

- **Day 1 post:** [see build-in-public/day-01-thread.md](build-in-public/day-01-thread.md)
- Twitter/X: [@ahmedf](https://twitter.com) — `#Feddan #BuildInPublic`
- Updates posted weekly

---

## Roadmap

- [x] Phone OTP authentication
- [x] Farm profile (GPS + crop selection + planting date)
- [x] Daily task engine (NASA POWER + FAO-56)
- [x] Push notifications (FCM daily digest)
- [ ] Google Maps farm location picker
- [ ] Weather widget on home screen
- [ ] Historical task completion analytics
- [ ] Multi-language support (additional dialects)
- [ ] Offline-first sync

---

## License

MIT © 2026 Ahmed Faruk
