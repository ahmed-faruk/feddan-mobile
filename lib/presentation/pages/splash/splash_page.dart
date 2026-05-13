import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// Navigation away from this screen is handled by AppRouter.redirect,
// not here — GoRouter redirects '/' to '/auth' or '/home' synchronously
// during route matching, so this widget only renders as a brief flash
// if the redirect somehow doesn't fire (fallback branding screen).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'فدان',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Feddan',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
