import 'package:go_router/go_router.dart';

import '../../presentation/pages/auth/auth_page.dart';
import '../../presentation/pages/farm_profile/farm_profile_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/splash/splash_page.dart';

class AppRouter {
  static final config = GoRouter(
    initialLocation: '/',
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
        builder: (context, state) => const FarmProfilePage(),
      ),
    ],
  );
}
