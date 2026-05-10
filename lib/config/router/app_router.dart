import 'package:go_router/go_router.dart';

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
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
