import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/language/language_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final isArabic = state.locale.languageCode == 'ar';
        return Scaffold(
          appBar: AppBar(
            title: Text(isArabic ? 'مزرعتي' : 'My Farm'),
            actions: [
              TextButton(
                onPressed: () => context.read<LanguageBloc>().add(
                      LanguageChanged(
                        isArabic ? const Locale('en') : const Locale('ar'),
                      ),
                    ),
                child: Text(
                  isArabic ? 'EN' : 'ع',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                isArabic ? 'مرحباً بك في فدان' : 'Welcome to Feddan',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
