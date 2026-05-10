part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

final class TasksLoadRequested extends TaskEvent {
  final List<String> farmIds;
  const TasksLoadRequested(this.farmIds);

  @override
  List<Object?> get props => [farmIds];
}

final class TaskCompleted extends TaskEvent {
  final String farmId;
  final String taskId;
  const TaskCompleted({required this.farmId, required this.taskId});

  @override
  List<Object?> get props => [farmId, taskId];
}

final class TaskSkipped extends TaskEvent {
  final String farmId;
  final String taskId;
  const TaskSkipped({required this.farmId, required this.taskId});

  @override
  List<Object?> get props => [farmId, taskId];
}
