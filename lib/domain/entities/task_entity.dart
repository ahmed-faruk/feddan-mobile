import 'package:equatable/equatable.dart';

enum TaskType { irrigate, irrigateSkip, fertilize, inspect }

enum TaskPriority { high, normal, low }

enum TaskStatus { pending, done, skipped }

class TaskEntity extends Equatable {
  final String id;
  final String farmId;
  final String cropType;
  final TaskType type;
  final TaskPriority priority;
  final DateTime scheduledDate;
  final String messageAr;
  final String messageEn;
  final TaskStatus status;
  final double? waterDemandMm;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.farmId,
    required this.cropType,
    required this.type,
    required this.priority,
    required this.scheduledDate,
    required this.messageAr,
    required this.messageEn,
    required this.status,
    this.waterDemandMm,
    required this.createdAt,
  });

  bool get isPending => status == TaskStatus.pending;
  bool get isActionable => type == TaskType.irrigate || type == TaskType.fertilize || type == TaskType.inspect;

  @override
  List<Object?> get props => [
        id, farmId, cropType, type, priority,
        scheduledDate, messageAr, messageEn, status,
        waterDemandMm, createdAt,
      ];
}
