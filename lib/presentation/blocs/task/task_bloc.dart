import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/complete_task_usecase.dart';
import '../../../domain/usecases/get_today_tasks_usecase.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTodayTasksUseCase _getTodayTasks;
  final CompleteTaskUseCase _completeTask;

  TaskBloc({
    required GetTodayTasksUseCase getTodayTasks,
    required CompleteTaskUseCase completeTask,
  })  : _getTodayTasks = getTodayTasks,
        _completeTask = completeTask,
        super(const TaskState()) {
    on<TasksLoadRequested>(_onLoadRequested);
    on<TaskCompleted>(_onCompleted);
    on<TaskSkipped>(_onSkipped);
  }

  Future<void> _onLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskLoadStatus.loading));
    try {
      final tasks = await _getTodayTasks(event.farmIds);
      emit(state.copyWith(status: TaskLoadStatus.loaded, tasks: tasks));
    } catch (e) {
      emit(state.copyWith(
        status: TaskLoadStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCompleted(
    TaskCompleted event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(clearActionError: true));
    try {
      await _completeTask(farmId: event.farmId, taskId: event.taskId);
      final updated = state.tasks
          .map((t) => t.id == event.taskId ? _withStatus(t, TaskStatus.done) : t)
          .toList();
      emit(state.copyWith(tasks: updated));
    } catch (_) {
      emit(state.copyWith(actionError: 'فشل تحديث المهمة — تحقق من الاتصال'));
    }
  }

  Future<void> _onSkipped(
    TaskSkipped event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(clearActionError: true));
    try {
      await _completeTask(
          farmId: event.farmId, taskId: event.taskId, skip: true);
      final updated = state.tasks
          .map((t) =>
              t.id == event.taskId ? _withStatus(t, TaskStatus.skipped) : t)
          .toList();
      emit(state.copyWith(tasks: updated));
    } catch (_) {
      emit(state.copyWith(actionError: 'فشل تحديث المهمة — تحقق من الاتصال'));
    }
  }

  TaskEntity _withStatus(TaskEntity task, TaskStatus status) => TaskEntity(
        id: task.id,
        farmId: task.farmId,
        cropType: task.cropType,
        type: task.type,
        priority: task.priority,
        scheduledDate: task.scheduledDate,
        messageAr: task.messageAr,
        messageEn: task.messageEn,
        status: status,
        waterDemandMm: task.waterDemandMm,
        createdAt: task.createdAt,
      );
}
