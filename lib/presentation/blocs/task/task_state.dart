part of 'task_bloc.dart';

enum TaskLoadStatus { initial, loading, loaded, failure }

final class TaskState extends Equatable {
  final TaskLoadStatus status;
  final List<TaskEntity> tasks;
  final String? errorMessage;
  final String? actionError; // transient error from complete/skip actions

  const TaskState({
    this.status = TaskLoadStatus.initial,
    this.tasks = const [],
    this.errorMessage,
    this.actionError,
  });

  List<TaskEntity> get pendingTasks =>
      tasks.where((t) => t.isPending).toList();

  TaskState copyWith({
    TaskLoadStatus? status,
    List<TaskEntity>? tasks,
    String? errorMessage,
    String? actionError,
    bool clearActionError = false,
  }) =>
      TaskState(
        status: status ?? this.status,
        tasks: tasks ?? this.tasks,
        errorMessage: errorMessage ?? this.errorMessage,
        actionError: clearActionError ? null : (actionError ?? this.actionError),
      );

  @override
  List<Object?> get props => [status, tasks, errorMessage, actionError];
}
