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

  static String _typeToString(TaskType t) => switch (t) {
        TaskType.irrigate     => 'IRRIGATE',
        TaskType.irrigateSkip => 'IRRIGATE_SKIP',
        TaskType.fertilize    => 'FERTILIZE',
        TaskType.inspect      => 'INSPECT',
      };

  static String _priorityToString(TaskPriority p) => switch (p) {
        TaskPriority.high   => 'HIGH',
        TaskPriority.normal => 'NORMAL',
        TaskPriority.low    => 'LOW',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmId': farmId,
        'cropType': cropType,
        'type': _typeToString(type),
        'priority': _priorityToString(priority),
        'scheduledDate': scheduledDate.millisecondsSinceEpoch,
        'messageAr': messageAr,
        'messageEn': messageEn,
        'status': statusToString(status),
        'waterDemandMm': waterDemandMm,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        farmId: json['farmId'] as String,
        cropType: json['cropType'] as String,
        type: _parseType(json['type'] as String),
        priority: _parsePriority(json['priority'] as String),
        scheduledDate: DateTime.fromMillisecondsSinceEpoch(
            json['scheduledDate'] as int),
        messageAr: json['messageAr'] as String,
        messageEn: json['messageEn'] as String,
        status: _parseStatus(json['status'] as String),
        waterDemandMm: (json['waterDemandMm'] as num?)?.toDouble(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'] as int),
      );
}
