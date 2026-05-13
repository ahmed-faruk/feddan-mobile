import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';
import '../datasources/remote/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;
  final TaskLocalDataSource _local;

  const TaskRepositoryImpl(this._remote, this._local);

  @override
  Future<List<TaskEntity>> getTasksForDate({
    required String farmId,
    required DateTime date,
  }) async {
    try {
      final tasks = await _remote.getTasksForDate(farmId: farmId, date: date);
      _local.save(farmId: farmId, date: date, tasks: tasks);
      return tasks;
    } catch (e) {
      // Network or Firestore error — serve from Hive cache if available.
      final cached = _local.load(farmId: farmId, date: date);
      if (cached != null) return cached;
      final msg = e is FirebaseException
          ? (e.message ?? 'Firestore error')
          : e.toString();
      throw ServerFailure(msg);
    }
  }

  @override
  Future<void> updateTaskStatus({
    required String farmId,
    required String taskId,
    required TaskStatus status,
  }) async {
    try {
      await _remote.updateTaskStatus(
          farmId: farmId, taskId: taskId, status: status);
      // Mirror the status change into the local cache so the next offline
      // session shows the task correctly.
      _local.patchStatus(farmId: farmId, taskId: taskId, status: status);
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error');
    }
  }
}
