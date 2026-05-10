import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTodayTasksUseCase {
  final TaskRepository _repository;
  const GetTodayTasksUseCase(this._repository);

  Future<List<TaskEntity>> call(List<String> farmIds) async {
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    final results = await Future.wait(
      farmIds.map((id) => _repository.getTasksForDate(farmId: id, date: date)),
    );

    final all = results.expand((list) => list).toList()
      ..sort((a, b) {
        // HIGH first, then by type (IRRIGATE before others)
        final pCmp = a.priority.index.compareTo(b.priority.index);
        if (pCmp != 0) return pCmp;
        return a.type.index.compareTo(b.type.index);
      });

    return all;
  }
}
