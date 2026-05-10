import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.farmId,
    required super.cropType,
    required super.type,
    required super.priority,
    required super.scheduledDate,
    required super.messageAr,
    required super.messageEn,
    required super.status,
    super.waterDemandMm,
    required super.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc, String farmId) {
    final d = doc.data()! as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      farmId: farmId,
      cropType: d['cropType'] as String,
      type: _parseType(d['type'] as String),
      priority: _parsePriority(d['priority'] as String),
      scheduledDate: (d['scheduledDate'] as Timestamp).toDate(),
      messageAr: d['messageAr'] as String,
      messageEn: d['messageEn'] as String,
      status: _parseStatus(d['status'] as String),
      waterDemandMm: (d['waterDemandMm'] as num?)?.toDouble(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  static TaskType _parseType(String s) => switch (s) {
        'IRRIGATE'      => TaskType.irrigate,
        'IRRIGATE_SKIP' => TaskType.irrigateSkip,
        'FERTILIZE'     => TaskType.fertilize,
        'INSPECT'       => TaskType.inspect,
        _               => TaskType.inspect,
      };

  static TaskPriority _parsePriority(String s) => switch (s) {
        'HIGH'   => TaskPriority.high,
        'NORMAL' => TaskPriority.normal,
        _        => TaskPriority.low,
      };

  static TaskStatus _parseStatus(String s) => switch (s) {
        'DONE'    => TaskStatus.done,
        'SKIPPED' => TaskStatus.skipped,
        _         => TaskStatus.pending,
      };

  static String statusToString(TaskStatus s) => switch (s) {
        TaskStatus.done    => 'DONE',
        TaskStatus.skipped => 'SKIPPED',
        TaskStatus.pending => 'PENDING',
      };
}
