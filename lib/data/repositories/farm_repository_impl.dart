import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/farm_entity.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasources/remote/farm_remote_datasource.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FarmRemoteDataSource _remote;

  const FarmRepositoryImpl(this._remote);

  @override
  Future<FarmEntity> createFarm(CreateFarmParams params) async {
    try {
      return await _remote.createFarm(params);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firestore error');
    }
  }

  @override
  Future<List<FarmEntity>> getFarms(String ownerId) async {
    try {
      return await _remote.getFarms(ownerId);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firestore error');
    }
  }
}
