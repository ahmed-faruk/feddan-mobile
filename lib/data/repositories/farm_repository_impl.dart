import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/farm_entity.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasources/local/farm_local_datasource.dart';
import '../datasources/remote/farm_remote_datasource.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FarmRemoteDataSource _remote;
  final FarmLocalDataSource _local;

  const FarmRepositoryImpl(this._remote, this._local);

  @override
  Future<FarmEntity> createFarm(CreateFarmParams params) async {
    try {
      return await _remote.createFarm(params);
    } on Failure {
      rethrow; // AuthFailure (unauthenticated) must surface as-is to the BLoC
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error');
    }
  }

  @override
  Future<void> updateFarm(String farmId, CreateFarmParams params) async {
    try {
      return await _remote.updateFarm(farmId, params);
    } on Failure {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error');
    }
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    try {
      return await _remote.deleteFarm(farmId);
    } on Failure {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error');
    }
  }

  @override
  Future<List<FarmEntity>> getFarms(String ownerId) async {
    try {
      final farms = await _remote.getFarms(ownerId);
      // Write-through: keep the local cache current after every successful fetch.
      _local.save(ownerId: ownerId, farms: farms);
      return farms;
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error');
    }
  }

  @override
  Future<List<FarmEntity>?> getCachedFarms(String ownerId) async =>
      _local.load(ownerId: ownerId);
}
