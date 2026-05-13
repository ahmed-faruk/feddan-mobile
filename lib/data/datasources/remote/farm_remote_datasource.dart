import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/repositories/farm_repository.dart';
import '../../models/farm_model.dart';

class FarmRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FarmRemoteDataSource(this._firestore);

  Future<FarmModel> createFarm(CreateFarmParams params) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw const AuthFailure('User not authenticated');

    final ref = _firestore.collection('farms').doc();
    final model = FarmModel.fromParams(ref.id, params, uid);
    await ref.set(model.toJson());
    return model;
  }

  Future<void> updateFarm(String farmId, CreateFarmParams params) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw const AuthFailure('User not authenticated');

    await _firestore.collection('farms').doc(farmId).update({
      'name': params.name,
      'latitude': params.latitude,
      'longitude': params.longitude,
      'cropTypes': params.cropTypes,
      'plantingDate': Timestamp.fromDate(params.plantingDate),
    });
  }

  Future<void> deleteFarm(String farmId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw const AuthFailure('User not authenticated');

    await _firestore.collection('farms').doc(farmId).delete();
  }

  Future<List<FarmModel>> getFarms(String ownerId) async {
    final snapshot = await _firestore
        .collection('farms')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map(FarmModel.fromFirestore).toList();
  }
}
