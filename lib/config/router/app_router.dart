import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/farm_entity.dart';
import '../../presentation/pages/auth/auth_page.dart';
import '../../presentation/pages/farm_profile/farm_profile_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/splash/splash_page.dart';

class AppRouter {
  // Firebase is guaranteed initialised before runApp() in main.dart, so
  // currentUser is reliable here. GoRouter redirect handles the '/' → auth/home
  // decision synchronously during route matching — no frame-timing issues.
  static final config = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (state.matchedLocation == '/') {
        return FirebaseAuth.instance.currentUser != null ? '/home' : '/auth';
      }
      return null;
    },
    // Firebase Auth reCAPTCHA completion returns a deep link using our custom
    // URL scheme (app-1-...). Flutter's platform channel forwards it to GoRouter
    // which can't match it as a route. Silently ignore unknown URLs so Firebase
    // Auth can process the callback without a navigation error.
    onException: (context, state, router) {},
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/farm-profile',
        builder: (context, state) => FarmProfilePage(
          existingFarm: state.extra as FarmEntity?,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
