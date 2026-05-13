import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../config/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/farm_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/farm/farm_bloc.dart';
import '../../blocs/language/language_bloc.dart';

class FarmProfilePage extends StatelessWidget {
  const FarmProfilePage({super.key, this.existingFarm});

  final FarmEntity? existingFarm;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FarmBloc(
        createFarm: getIt(),
        updateFarm: getIt(),
        deleteFarm: getIt(),
        existingFarm: existingFarm,
      ),
      child: const _FarmProfileView(),
    );
  }
}

class _FarmProfileView extends StatelessWidget {
  const _FarmProfileView();

  void _confirmDelete(
      BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteFarmTitle),
        content: Text(l10n.deleteFarmWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<FarmBloc>().add(const FarmDeleteRequested());
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';

    return BlocListener<FarmBloc, FarmState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == FarmStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.isEditMode
                ? l10n.farmUpdatedSuccess
                : l10n.farmSavedSuccess),
            backgroundColor: AppColors.primary,
          ));
          context.go('/home');
        } else if (state.status == FarmStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.farmDeletedSuccess),
            backgroundColor: AppColors.textSecondary,
          ));
          context.go('/home');
        } else if (state.status == FarmStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.error,
          ));
        }
      },
      child: BlocBuilder<FarmBloc, FarmState>(
        buildWhen: (p, c) =>
            p.status != c.status || p.isEditMode != c.isEditMode,
        builder: (context, state) {
          final isBusy = state.status == FarmStatus.saving ||
              state.status == FarmStatus.deleting;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                  state.isEditMode ? l10n.editFarm : l10n.farmProfileTitle),
              leading: BackButton(onPressed: () => context.go('/home')),
              actions: [
                if (state.isEditMode)
                  IconButton(
                    icon: isBusy && state.status == FarmStatus.deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                    tooltip: l10n.deleteFarmTooltip,
                    onPressed:
                        isBusy ? null : () => _confirmDelete(context, l10n),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FarmNameField(),
                  const SizedBox(height: 24),
                  _LocationSection(isArabic: isArabic),
                  const SizedBox(height: 24),
                  _CropSelectionSection(),
                  const SizedBox(height: 24),
                  _PlantingDateSection(isArabic: isArabic),
                  const SizedBox(height: 32),
                  _SaveButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Farm Name ───────────────────────────────────────────────────────────────

class _FarmNameField extends StatefulWidget {
  const _FarmNameField();

  @override
  State<_FarmNameField> createState() => _FarmNameFieldState();
}

class _FarmNameFieldState extends State<_FarmNameField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        TextEditingController(text: context.read<FarmBloc>().state.name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.farmNameLabel,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ctrl,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: l10n.farmNameHint,
            prefixIcon: const Icon(Icons.agriculture_outlined),
          ),
          onChanged: (v) =>
              context.read<FarmBloc>().add(FarmNameChanged(v)),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.farmLocationTitle,
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
                  _MapPreview(state: state),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => context
                          .read<FarmBloc>()
                          .add(const FarmLocationRequested()),
                      icon: const Icon(Icons.my_location, size: 18),
                      label: Text(l10n.updateLocation),
                    ),
                  ),
                ],
              );
            }
            return _LocationButton(state: state);
          },
        ),
      ],
    );
  }
}

class _LocationButton extends StatelessWidget {
  final FarmState state;
  const _LocationButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        isLocating ? l10n.locating : l10n.useCurrentLocation,
        style: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}

class _MapPreview extends StatefulWidget {
  final FarmState state;
  const _MapPreview({required this.state});

  @override
  State<_MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<_MapPreview> {
  GoogleMapController? _mapController;

  LatLng get _position =>
      LatLng(widget.state.latitude!, widget.state.longitude!);

  @override
  void didUpdateWidget(_MapPreview old) {
    super.didUpdateWidget(old);
    // Pan the camera when the GPS refreshes or user drags the pin.
    if (old.state.latitude != widget.state.latitude ||
        old.state.longitude != widget.state.longitude) {
      _mapController?.animateCamera(
          CameraUpdate.newLatLng(_position));
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _position, zoom: 14),
              markers: {
                Marker(
                  markerId: const MarkerId('farm'),
                  position: _position,
                  draggable: true,
                  onDragEnd: (pos) => context.read<FarmBloc>().add(
                        FarmLocationPinChanged(
                            pos.latitude, pos.longitude),
                      ),
                ),
              },
              onTap: (pos) => context.read<FarmBloc>().add(
                    FarmLocationPinChanged(pos.latitude, pos.longitude),
                  ),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (c) => _mapController = c,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.tapMapToAdjust,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Crop Selection ────────────────────────────────────────────────────────────

class _CropSelectionSection extends StatelessWidget {
  const _CropSelectionSection();

  static const _arNames = {
    'tomato': 'طماطم', 'potato': 'بطاطس', 'eggplant': 'باذنجان',
    'pepper': 'فلفل', 'watermelon': 'بطيخ', 'cantaloupe': 'شمام',
    'honeydew': 'كنتالوب', 'cucumber': 'خيار', 'squash': 'كوسة',
    'zucchini': 'قرع',
  };

  String _label(String crop, bool isArabic) => isArabic
      ? (_arNames[crop] ?? crop)
      : crop[0].toUpperCase() + crop.substring(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cropsTitle,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.cropsSubtitle,
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
                  label: Text(_label(crop, isArabic)),
                  selected: selected,
                  onSelected: (_) =>
                      context.read<FarmBloc>().add(FarmCropToggled(crop)),
                  selectedColor: AppColors.primary.withAlpha(40),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.plantingDate,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.plantingDateSubtitle,
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
                  firstDate: DateTime.now()
                      .subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  locale: isArabic
                      ? const Locale('ar')
                      : const Locale('en'),
                );
                if (picked != null && context.mounted) {
                  context
                      .read<FarmBloc>()
                      .add(FarmPlantingDateChanged(picked));
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
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
                          : l10n.selectDate,
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
                      const Icon(Icons.check_circle,
                          color: AppColors.primary),
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
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<FarmBloc, FarmState>(
      buildWhen: (p, c) =>
          p.isValid != c.isValid ||
          p.status != c.status ||
          p.isEditMode != c.isEditMode,
      builder: (context, state) {
        final isSaving = state.status == FarmStatus.saving;
        return ElevatedButton(
          onPressed: (state.isValid && !isSaving)
              ? () =>
                  context.read<FarmBloc>().add(const FarmSaveRequested())
              : null,
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(state.isEditMode ? l10n.updateFarm : l10n.saveFarm),
        );
      },
    );
  }
}
