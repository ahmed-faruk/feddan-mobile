import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/remote/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;

  const TaskRepositoryImpl(this._remote);

  @override
  Future<List<TaskEntity>> getTasksForDate({
    required String farmId,
    required DateTime date,
  }) async {
    try {
      return await _remote.getTasksForDate(farmId: farmId, date: date);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firestore error');
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
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firestore error');
    }
  }
}
