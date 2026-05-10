import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/repositories/farm_repository.dart';
import '../../models/farm_model.dart';

class FarmRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FarmRemoteDataSource(this._firestore);

  Future<FarmModel> createFarm(CreateFarmParams params) async {
    final ownerId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final ref = _firestore.collection('farms').doc();
    final model = FarmModel.fromParams(ref.id, params, ownerId);
    await ref.set(model.toJson());
    return model;
  }

  Future<List<FarmModel>> getFarms(String ownerId) async {
    final snapshot = await _firestore
        .collection('farms')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(FarmModel.fromFirestore).toList();
  }
}
