import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.agriculture,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'مرحباً بك في فدان' : 'Welcome to Feddan',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'أضف مزرعتك الأولى للبدء'
                        : 'Add your first farm to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/farm-profile'),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              isArabic ? 'إضافة مزرعة' : 'Add Farm',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
