import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CompleteTaskUseCase {
  final TaskRepository _repository;
  const CompleteTaskUseCase(this._repository);

  Future<void> call({
    required String farmId,
    required String taskId,
    bool skip = false,
  }) =>
      _repository.updateTaskStatus(
        farmId: farmId,
        taskId: taskId,
        status: skip ? TaskStatus.skipped : TaskStatus.done,
      );
}
