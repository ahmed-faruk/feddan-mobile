import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTodayTasksUseCase {
  final TaskRepository _repository;
  const GetTodayTasksUseCase(this._repository);

  Future<List<TaskEntity>> call(List<String> farmIds) async {
    if (farmIds.isEmpty) return [];

    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    // Isolate per-farm failures — one bad query doesn't wipe the whole list.
    final results = await Future.wait(
      farmIds.map((id) async {
        try {
          return await _repository.getTasksForDate(farmId: id, date: date);
        } catch (_) {
          return <TaskEntity>[];
        }
      }),
    );

    return results
        .expand((list) => list)
        .toList()
      ..sort((a, b) {
        final pCmp = a.priority.index.compareTo(b.priority.index);
        if (pCmp != 0) return pCmp;
        return a.type.index.compareTo(b.type.index);
      });
  }
}
