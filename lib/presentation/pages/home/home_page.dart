import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/farm_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/weather_snapshot.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/farm_list/farm_list_cubit.dart';
import '../../blocs/farm_list/farm_list_state.dart';
import '../../blocs/language/language_bloc.dart';
import '../../blocs/task/task_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<FarmListCubit>()..loadFarms(),
        ),
        BlocProvider(create: (_) => getIt<TaskBloc>()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';

    return MultiBlocListener(
      listeners: [
        BlocListener<FarmListCubit, FarmListState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == FarmListStatus.loaded,
          listener: (context, state) {
            context.read<TaskBloc>().add(TasksLoadRequested(state.farmIds));
          },
        ),
        BlocListener<TaskBloc, TaskState>(
          listenWhen: (p, c) =>
              c.actionError != null && p.actionError != c.actionError,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.taskUpdateError),
              backgroundColor: AppColors.error,
            ));
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == AuthStatus.initial,
          listener: (context, _) => context.go('/auth'),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appName),
          actions: [
            // Language toggle
            TextButton(
              onPressed: () => context.read<LanguageBloc>().add(
                    LanguageChanged(
                      isArabic
                          ? const Locale('en')
                          : const Locale('ar'),
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
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              tooltip: l10n.settings,
              onPressed: () => context.push('/settings'),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: l10n.signOut,
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthSignOutRequested()),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await context.read<FarmListCubit>().refresh();
          },
          child: BlocBuilder<FarmListCubit, FarmListState>(
            builder: (context, farmState) {
              // Initial load or first-time loading with no data yet.
              if (farmState.status == FarmListStatus.initial ||
                  (farmState.status == FarmListStatus.loading &&
                      !farmState.hasFarms)) {
                return const Center(child: CircularProgressIndicator());
              }

              // M3: Both Firestore and Hive failed — explicit error card instead
              // of a blank screen or infinite spinner.
              if (farmState.status == FarmListStatus.failure) {
                return _FarmLoadError(
                  onRetry: () => context.read<FarmListCubit>().refresh(),
                );
              }

              if (farmState.status == FarmListStatus.loaded &&
                  !farmState.hasFarms) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [_EmptyFarmsCard()],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // H2: Show an offline banner when farms came from Hive cache.
                  if (farmState.fromCache) const _OfflineBanner(),
                  _FarmSection(farms: farmState.farms),
                  const SizedBox(height: 16),
                  _WeatherSection(farms: farmState.farms),
                  const SizedBox(height: 8),
                  _TodayHeader(),
                  const SizedBox(height: 12),
                  _TaskList(),
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/farm-profile'),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            l10n.addFarm,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ─── Farm Load Error (M3) ─────────────────────────────────────────────────────

class _FarmLoadError extends StatelessWidget {
  final VoidCallback onRetry;
  const _FarmLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              l10n.tasksLoadError,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Offline Banner (H2) ─────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 16, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.offlineBanner,
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyFarmsCard extends StatelessWidget {
  const _EmptyFarmsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            const Icon(Icons.agriculture, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              l10n.welcome,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.welcomeBody,
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/farm-profile'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addFarm),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Farm Section ─────────────────────────────────────────────────────────────

class _FarmSection extends StatelessWidget {
  final List<FarmEntity> farms;
  const _FarmSection({required this.farms});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.myFarms,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              l10n.farmCount(farms.length),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...farms.map((farm) => _FarmChip(farm: farm)),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.add,
                    size: 16, color: AppColors.primary),
                label: Text(
                  l10n.add,
                  style: const TextStyle(color: AppColors.primary),
                ),
                backgroundColor: AppColors.primary.withAlpha(20),
                side:
                    const BorderSide(color: AppColors.primary, width: 0.5),
                onPressed: () => context.push('/farm-profile'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FarmChip extends StatelessWidget {
  final FarmEntity farm;
  const _FarmChip({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.agriculture, size: 14, color: Colors.white),
        ),
        label: Text(farm.name,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.primary, width: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        onPressed: () => context.push('/farm-profile', extra: farm),
      ),
    );
  }
}

// ─── Weather Section ──────────────────────────────────────────────────────────

class _WeatherSection extends StatelessWidget {
  final List<FarmEntity> farms;
  const _WeatherSection({required this.farms});

  @override
  Widget build(BuildContext context) {
    // Show weather for the first farm that has a latestWeather snapshot.
    final WeatherSnapshot? weather =
        farms.map((f) => f.latestWeather).whereType<WeatherSnapshot>().firstOrNull;

    if (weather == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.weatherToday,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeatherStat(
                  icon: Icons.thermostat,
                  iconColor: AppColors.error,
                  value: '${weather.maxTempC.toStringAsFixed(0)}°',
                  label: l10n.maxTemp,
                ),
                _WeatherStat(
                  icon: Icons.water_drop_outlined,
                  iconColor: AppColors.sky,
                  value: '${weather.humidityPct.toStringAsFixed(0)}%',
                  label: l10n.humidity,
                ),
                _WeatherStat(
                  icon: Icons.umbrella_outlined,
                  iconColor: AppColors.sky,
                  value: '${weather.rainfall.toStringAsFixed(1)} مم',
                  label: l10n.rainfallLabel,
                ),
                _WeatherStat(
                  icon: Icons.water_drop,
                  iconColor: AppColors.primary,
                  value: '${weather.et0.toStringAsFixed(1)} مم',
                  label: l10n.et0Label,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _WeatherStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

// ─── Today Header ─────────────────────────────────────────────────────────────

class _TodayHeader extends StatelessWidget {
  const _TodayHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          l10n.todayTasks,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          '${now.day}/${now.month}/${now.year}',
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

// ─── Task List ────────────────────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  const _TaskList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        switch (state.status) {
          case TaskLoadStatus.initial:
          case TaskLoadStatus.loading:
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            );
          case TaskLoadStatus.failure:
            return _TaskError();
          case TaskLoadStatus.loaded:
            if (state.tasks.isEmpty) {
              return _NoTasksCard();
            }
            return Column(
              children: state.tasks
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TaskCard(task: t),
                      ))
                  .toList(),
            );
        }
      },
    );
  }
}

class _NoTasksCard extends StatelessWidget {
  const _NoTasksCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.task_alt, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(l10n.noTasksToday,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.tasksArriveDaily,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskError extends StatelessWidget {
  const _TaskError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: AppColors.error.withAlpha(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.tasksLoadError,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Task Card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  const _TaskCard({required this.task});

  Color get _priorityColor => switch (task.priority) {
        TaskPriority.high => AppColors.error,
        TaskPriority.normal => AppColors.accent,
        TaskPriority.low => AppColors.textSecondary,
      };

  IconData get _typeIcon => switch (task.type) {
        TaskType.irrigate => Icons.water_drop,
        TaskType.irrigateSkip => Icons.water_drop_outlined,
        TaskType.fertilize => Icons.eco,
        TaskType.inspect => Icons.search,
      };

  String _priorityLabel(AppLocalizations l10n) => switch (task.priority) {
        TaskPriority.high => l10n.priorityHigh,
        TaskPriority.normal => l10n.priorityNormal,
        TaskPriority.low => l10n.priorityLow,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final isDone = task.status != TaskStatus.pending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _priorityColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon, color: _priorityColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _priorityColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _priorityLabel(l10n),
                      style: TextStyle(
                        color: _priorityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic ? task.messageAr : task.messageEn,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.4,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isDone ? AppColors.textSecondary : null,
                    ),
                  ),
                  if (task.waterDemandMm != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.water_drop,
                            size: 13, color: AppColors.sky),
                        const SizedBox(width: 4),
                        Text(
                          l10n.waterDemand(
                              task.waterDemandMm!.toStringAsFixed(1)),
                          style: const TextStyle(
                              color: AppColors.sky, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!isDone && task.isActionable)
              Column(
                children: [
                  _ActionBtn(
                    icon: Icons.check_circle_outline,
                    color: AppColors.primary,
                    tooltip: l10n.taskDone,
                    onTap: () => context.read<TaskBloc>().add(
                          TaskCompleted(
                              farmId: task.farmId, taskId: task.id),
                        ),
                  ),
                  const SizedBox(height: 4),
                  _ActionBtn(
                    icon: Icons.close,
                    color: AppColors.textSecondary,
                    tooltip: l10n.taskSkip,
                    onTap: () => context.read<TaskBloc>().add(
                          TaskSkipped(
                              farmId: task.farmId, taskId: task.id),
                        ),
                  ),
                ],
              )
            else if (isDone)
              Icon(
                task.status == TaskStatus.done
                    ? Icons.check_circle
                    : Icons.skip_next,
                color: task.status == TaskStatus.done
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
