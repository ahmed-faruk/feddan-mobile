import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/farm/farm_bloc.dart';
import '../../blocs/language/language_bloc.dart';

class FarmProfilePage extends StatelessWidget {
  const FarmProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FarmBloc>(),
      child: const _FarmProfileView(),
    );
  }
}

class _FarmProfileView extends StatelessWidget {
  const _FarmProfileView();

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';

    return BlocListener<FarmBloc, FarmState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == FarmStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'تم حفظ المزرعة بنجاح' : 'Farm saved successfully',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          context.go('/home');
        } else if (state.status == FarmStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'إضافة مزرعة' : 'Add Farm'),
          leading: BackButton(onPressed: () => context.go('/home')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FarmNameField(isArabic: isArabic),
              const SizedBox(height: 24),
              _LocationSection(isArabic: isArabic),
              const SizedBox(height: 24),
              _CropSelectionSection(isArabic: isArabic),
              const SizedBox(height: 24),
              _PlantingDateSection(isArabic: isArabic),
              const SizedBox(height: 32),
              _SaveButton(isArabic: isArabic),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Farm Name ───────────────────────────────────────────────────────────────

class _FarmNameField extends StatelessWidget {
  final bool isArabic;
  const _FarmNameField({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'اسم المزرعة' : 'Farm Name',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: isArabic ? 'مثال: مزرعة الفيوم' : 'e.g. North Farm',
            prefixIcon: const Icon(Icons.agriculture_outlined),
          ),
          onChanged: (v) => context.read<FarmBloc>().add(FarmNameChanged(v)),
        ),
      ],
    );
  }
}

// ─── Location ─────────────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  final bool isArabic;
  const _LocationSection({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'موقع المزرعة' : 'Farm Location',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        BlocBuilder<FarmBloc, FarmState>(
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.latitude != c.latitude ||
              p.longitude != c.longitude,
          builder: (context, state) {
            if (state.hasLocation) {
              return Column(
                children: [
                  _LocationDisplay(state: state, isArabic: isArabic),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => context
                          .read<FarmBloc>()
                          .add(const FarmLocationRequested()),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(
                        isArabic ? 'إعادة تحديد الموقع' : 'Update location',
                      ),
                    ),
                  ),
                ],
              );
            }
            return _LocationButton(state: state, isArabic: isArabic);
          },
        ),
      ],
    );
  }
}

class _LocationButton extends StatelessWidget {
  final FarmState state;
  final bool isArabic;
  const _LocationButton({required this.state, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final isLocating = state.status == FarmStatus.locating;
    return OutlinedButton.icon(
      onPressed: isLocating
          ? null
          : () =>
              context.read<FarmBloc>().add(const FarmLocationRequested()),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: AppColors.primary),
      ),
      icon: isLocating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.my_location, color: AppColors.primary),
      label: Text(
        isLocating
            ? (isArabic ? 'جارٍ تحديد الموقع...' : 'Locating...')
            : (isArabic
                ? 'استخدام موقعي الحالي'
                : 'Use my current location'),
        style: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}

class _LocationDisplay extends StatelessWidget {
  final FarmState state;
  final bool isArabic;
  const _LocationDisplay({required this.state, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'الموقع المحدد' : 'Location set',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${state.latitude!.toStringAsFixed(5)}, ${state.longitude!.toStringAsFixed(5)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.primary),
        ],
      ),
    );
  }
}

// ─── Crop Selection ────────────────────────────────────────────────────────────

class _CropSelectionSection extends StatelessWidget {
  final bool isArabic;
  const _CropSelectionSection({required this.isArabic});

  static const _arNames = {
    'tomato': 'طماطم',
    'potato': 'بطاطس',
    'eggplant': 'باذنجان',
    'pepper': 'فلفل',
    'watermelon': 'بطيخ',
    'cantaloupe': 'شمام',
    'honeydew': 'كنتالوب',
    'cucumber': 'خيار',
    'squash': 'كوسة',
    'zucchini': 'قرع',
  };

  String _label(String crop) => isArabic
      ? (_arNames[crop] ?? crop)
      : crop[0].toUpperCase() + crop.substring(1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'المحاصيل' : 'Crops',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          isArabic ? 'اختر محاصيل مزرعتك' : 'Select your farm crops',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        BlocBuilder<FarmBloc, FarmState>(
          buildWhen: (p, c) => p.selectedCrops != c.selectedCrops,
          builder: (context, state) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.supportedCrops.map((crop) {
                final selected = state.selectedCrops.contains(crop);
                return FilterChip(
                  label: Text(_label(crop)),
                  selected: selected,
                  onSelected: (_) =>
                      context.read<FarmBloc>().add(FarmCropToggled(crop)),
                  selectedColor: AppColors.primary.withAlpha(40),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ─── Planting Date ────────────────────────────────────────────────────────────

class _PlantingDateSection extends StatelessWidget {
  final bool isArabic;
  const _PlantingDateSection({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'تاريخ الزراعة' : 'Planting Date',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          isArabic ? 'متى زرعت هذا الموسم؟' : 'When did you plant this season?',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        BlocBuilder<FarmBloc, FarmState>(
          buildWhen: (p, c) => p.plantingDate != c.plantingDate,
          builder: (context, state) {
            final date = state.plantingDate;
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  locale: isArabic ? const Locale('ar') : const Locale('en'),
                );
                if (picked != null && context.mounted) {
                  context
                      .read<FarmBloc>()
                      .add(FarmPlantingDateChanged(picked));
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: date != null
                        ? AppColors.primary.withAlpha(80)
                        : AppColors.textSecondary.withAlpha(100),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: date != null
                      ? AppColors.primary.withAlpha(20)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: date != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      date != null
                          ? '${date.day}/${date.month}/${date.year}'
                          : (isArabic ? 'اختر التاريخ' : 'Select date'),
                      style: TextStyle(
                        color: date != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: date != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    if (date != null)
                      const Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Save Button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool isArabic;
  const _SaveButton({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FarmBloc, FarmState>(
      buildWhen: (p, c) => p.isValid != c.isValid || p.status != c.status,
      builder: (context, state) {
        final isSaving = state.status == FarmStatus.saving;
        return ElevatedButton(
          onPressed: (state.isValid && !isSaving)
              ? () => context.read<FarmBloc>().add(const FarmSaveRequested())
              : null,
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(isArabic ? 'حفظ المزرعة' : 'Save Farm'),
        );
      },
    );
  }
}
