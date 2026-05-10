import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/language/language_bloc.dart';
import '../../blocs/task/task_bloc.dart';
import '../../../domain/entities/task_entity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<TaskBloc>();
        // Load today's tasks for all farms owned by current user.
        // Farm IDs are resolved via Firestore in a real flow; for MVP we
        // trigger a load and let the tasks section display results.
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) bloc.add(TasksLoadRequested(const []));
        return bloc;
      },
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, langState) {
        final isArabic = langState.locale.languageCode == 'ar';
        return Scaffold(
          appBar: AppBar(
            title: Text(isArabic ? 'فدان' : 'Feddan'),
            actions: [
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
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<TaskBloc>().add(TasksLoadRequested(const []));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TodayHeader(isArabic: isArabic),
                const SizedBox(height: 16),
                _TaskList(isArabic: isArabic),
              ],
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

// ─── Today Header ─────────────────────────────────────────────────────────────

class _TodayHeader extends StatelessWidget {
  final bool isArabic;
  const _TodayHeader({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'مهام اليوم' : "Today's Tasks",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          dateStr,
          style: const TextStyle(color: AppColors.textSecondary),
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
        if (state.status == TaskLoadStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final tasks = state.tasks;
        if (tasks.isEmpty) {
          return _EmptyTasksCard(isArabic: isArabic);
        }

        return Column(
          children: tasks
              .map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TaskCard(task: t, isArabic: isArabic),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  final bool isArabic;
  const _EmptyTasksCard({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.task_alt, size: 56, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'لا توجد مهام اليوم'
                  : 'No tasks for today',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              isArabic
                  ? 'أضف مزرعة لبدء استقبال المهام اليومية'
                  : 'Add a farm to start receiving daily tasks',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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
        TaskPriority.high   => AppColors.error,
        TaskPriority.normal => AppColors.accent,
        TaskPriority.low    => AppColors.textSecondary,
      };

  IconData get _typeIcon => switch (task.type) {
        TaskType.irrigate     => Icons.water_drop,
        TaskType.irrigateSkip => Icons.water_drop_outlined,
        TaskType.fertilize    => Icons.eco,
        TaskType.inspect      => Icons.search,
      };

  @override
  Widget build(BuildContext context) {
    final isDone = task.status != TaskStatus.pending;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority + type indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _priorityColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon, color: _priorityColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? task.messageAr : task.messageEn,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isDone ? AppColors.textSecondary : null,
                    ),
                  ),
                  if (task.waterDemandMm != null)
                    Text(
                      isArabic
                          ? '${task.waterDemandMm!.toStringAsFixed(1)} مم'
                          : '${task.waterDemandMm!.toStringAsFixed(1)}mm',
                      style: const TextStyle(
                        color: AppColors.sky,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            // Action buttons
            if (!isDone && task.isActionable)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: AppColors.primary),
                    tooltip: isArabic ? 'تم' : 'Done',
                    onPressed: () => context.read<TaskBloc>().add(
                          TaskCompleted(
                              farmId: task.farmId, taskId: task.id),
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary),
                    tooltip: isArabic ? 'تخطي' : 'Skip',
                    onPressed: () => context.read<TaskBloc>().add(
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
              ),
          ],
        ),
      ),
    );
  }
}
