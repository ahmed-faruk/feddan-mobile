import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasksForDate({
    required String farmId,
    required DateTime date,
  });

  Future<void> updateTaskStatus({
    required String farmId,
    required String taskId,
    required TaskStatus status,
  });
}
