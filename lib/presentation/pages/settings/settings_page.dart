import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/language/language_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale =
        context.watch<LanguageBloc>().state.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Language ──────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        l10n.language,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LanguageOption(
                    label: l10n.arabic,
                    code: 'ar',
                    selected: currentLocale == 'ar',
                  ),
                  const Divider(height: 1),
                  _LanguageOption(
                    label: l10n.english,
                    code: 'en',
                    selected: currentLocale == 'en',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selected
          ? null
          : () => context
              .read<LanguageBloc>()
              .add(LanguageChanged(Locale(code))),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
