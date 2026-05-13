import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../models/farm_model.dart';

class FarmLocalDataSource {
  static const boxName = 'farms_cache';

  Box<String> get _box => Hive.box<String>(boxName);

  // One cache entry per owner — all farms for a user stored together since
  // they are always fetched and displayed as a single list.
  static String _key(String ownerId) => 'farms_$ownerId';

  void save({required String ownerId, required List<FarmModel> farms}) {
    _box.put(
      _key(ownerId),
      jsonEncode(farms.map((f) => f.toHiveJson()).toList()),
    );
  }

  List<FarmModel>? load({required String ownerId}) {
    final raw = _box.get(_key(ownerId));
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => FarmModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
