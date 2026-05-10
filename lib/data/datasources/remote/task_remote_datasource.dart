import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/task_entity.dart';
import '../../models/task_model.dart';

class TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  const TaskRemoteDataSource(this._firestore);

  Future<List<TaskModel>> getTasksForDate({
    required String farmId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _firestore
        .collection('farms')
        .doc(farmId)
        .collection('tasks')
        .where('scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledDate', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledDate')
        .get();

    return snap.docs.map((doc) => TaskModel.fromFirestore(doc, farmId)).toList();
  }

  Future<void> updateTaskStatus({
    required String farmId,
    required String taskId,
    required TaskStatus status,
  }) =>
      _firestore
          .collection('farms')
          .doc(farmId)
          .collection('tasks')
          .doc(taskId)
          .update({'status': TaskModel.statusToString(status)});
}
