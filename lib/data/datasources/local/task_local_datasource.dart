import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/entities/task_entity.dart';
import '../../models/task_model.dart';

class TaskLocalDataSource {
  static const boxName = 'tasks_cache';

  Box<String> get _box => Hive.box<String>(boxName);

  static String _cacheKey(String farmId, DateTime date) =>
      '${farmId}_${date.year}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';

  void save({
    required String farmId,
    required DateTime date,
    required List<TaskModel> tasks,
  }) {
    _box.put(
      _cacheKey(farmId, date),
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  List<TaskModel>? load({required String farmId, required DateTime date}) {
    final raw = _box.get(_cacheKey(farmId, date));
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Patches the status of a single task in today's cached list so that
  // the next offline load reflects the user's last action.
  void patchStatus({
    required String farmId,
    required String taskId,
    required TaskStatus status,
  }) {
    final today = DateTime.now();
    final key = _cacheKey(farmId, today);
    final raw = _box.get(key);
    if (raw == null) return;

    final list = jsonDecode(raw) as List<dynamic>;
    final updated = list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      if (m['id'] == taskId) m['status'] = TaskModel.statusToString(status);
      return m;
    }).toList();

    _box.put(key, jsonEncode(updated));
  }
}
