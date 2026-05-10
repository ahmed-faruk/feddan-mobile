import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/farm_entity.dart';
import '../../../domain/entities/task_entity.dart';
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
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';

    return MultiBlocListener(
      listeners: [
        // Load tasks when farms finish loading
        BlocListener<FarmListCubit, FarmListState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == FarmListStatus.loaded,
          listener: (context, state) {
            context.read<TaskBloc>().add(TasksLoadRequested(state.farmIds));
          },
        ),
        // Show snackbar on task action errors (complete/skip failure)
        BlocListener<TaskBloc, TaskState>(
          listenWhen: (p, c) =>
              c.actionError != null && p.actionError != c.actionError,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: AppColors.error,
              ),
            );
          },
        ),
        // Redirect to auth when user signs out
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == AuthStatus.initial,
          listener: (context, _) => context.go('/auth'),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'فدان' : 'Feddan'),
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
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: isArabic ? 'تسجيل الخروج' : 'Sign out',
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
              if (farmState.status == FarmListStatus.initial ||
                  (farmState.status == FarmListStatus.loading &&
                      !farmState.hasFarms)) {
                return const Center(child: CircularProgressIndicator());
              }

              if (farmState.status == FarmListStatus.loaded &&
                  !farmState.hasFarms) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [_EmptyFarmsCard(isArabic: isArabic)],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _FarmSection(farms: farmState.farms, isArabic: isArabic),
                  const SizedBox(height: 24),
                  _TodayHeader(isArabic: isArabic),
                  const SizedBox(height: 12),
                  _TaskList(isArabic: isArabic),
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
            isArabic ? 'إضافة مزرعة' : 'Add Farm',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyFarmsCard extends StatelessWidget {
  final bool isArabic;
  const _EmptyFarmsCard({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            const Icon(Icons.agriculture, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'مرحباً بك في فدان' : 'Welcome to Feddan',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'أضف مزرعتك الأولى لتبدأ في استقبال\nمهام الري والتسميد اليومية'
                  : 'Add your first farm to start receiving\ndaily irrigation and fertilisation tasks',
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/farm-profile'),
              icon: const Icon(Icons.add),
              label: Text(isArabic ? 'إضافة مزرعة' : 'Add Farm'),
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
  final bool isArabic;
  const _FarmSection({required this.farms, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isArabic ? 'مزارعي' : 'My Farms',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${farms.length} ${isArabic ? (farms.length == 1 ? "مزرعة" : "مزارع") : (farms.length == 1 ? "farm" : "farms")}',
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
                  isArabic ? 'إضافة' : 'Add',
                  style: const TextStyle(color: AppColors.primary),
                ),
                backgroundColor: AppColors.primary.withAlpha(20),
                side: const BorderSide(color: AppColors.primary, width: 0.5),
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
      child: Chip(
        avatar: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.agriculture, size: 14, color: Colors.white),
        ),
        label: Text(farm.name,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.primary, width: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

// ─── Today Header ─────────────────────────────────────────────────────────────

class _TodayHeader extends StatelessWidget {
  final bool isArabic;
  const _TodayHeader({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          isArabic ? 'مهام اليوم' : "Today's Tasks",
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
  final bool isArabic;
  const _TaskList({required this.isArabic});

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
            return _TaskError(isArabic: isArabic);
          case TaskLoadStatus.loaded:
            if (state.tasks.isEmpty) {
              return _NoTasksCard(isArabic: isArabic);
            }
            return Column(
              children: state.tasks
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TaskCard(task: t, isArabic: isArabic),
                      ))
                  .toList(),
            );
        }
      },
    );
  }
}

class _NoTasksCard extends StatelessWidget {
  final bool isArabic;
  const _NoTasksCard({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.task_alt, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              isArabic ? 'لا توجد مهام اليوم' : 'No tasks today',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              isArabic
                  ? 'ستصلك المهام يومياً عند الساعة 6 صباحاً'
                  : 'Tasks arrive daily at 6am Cairo time',
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
  final bool isArabic;
  const _TaskError({required this.isArabic});

  @override
  Widget build(BuildContext context) {
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
                isArabic
                    ? 'فشل تحميل المهام — اسحب للأسفل لإعادة المحاولة'
                    : 'Failed to load tasks — pull to refresh',
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
  final bool isArabic;
  const _TaskCard({required this.task, required this.isArabic});

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

  String get _priorityLabel => switch (task.priority) {
        TaskPriority.high => isArabic ? 'عاجل' : 'URGENT',
        TaskPriority.normal => isArabic ? 'اليوم' : 'TODAY',
        TaskPriority.low => isArabic ? 'اختياري' : 'OPTIONAL',
      };

  @override
  Widget build(BuildContext context) {
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
                      _priorityLabel,
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
                          '${task.waterDemandMm!.toStringAsFixed(1)} ${isArabic ? "مم" : "mm"}',
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
                    tooltip: isArabic ? 'تم' : 'Done',
                    onTap: () => context.read<TaskBloc>().add(
                          TaskCompleted(
                              farmId: task.farmId, taskId: task.id),
                        ),
                  ),
                  const SizedBox(height: 4),
                  _ActionBtn(
                    icon: Icons.close,
                    color: AppColors.textSecondary,
                    tooltip: isArabic ? 'تخطي' : 'Skip',
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
