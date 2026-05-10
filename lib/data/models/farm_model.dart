import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/farm_entity.dart';
import '../../domain/repositories/farm_repository.dart';

class FarmModel extends FarmEntity {
  const FarmModel({
    super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.cropTypes,
    required super.ownerId,
    required super.createdAt,
  });

  factory FarmModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return FarmModel(
      id: doc.id,
      name: data['name'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      cropTypes: List<String>.from(data['cropTypes'] as List),
      ownerId: data['ownerId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory FarmModel.fromParams(
    String id,
    CreateFarmParams params,
    String ownerId,
  ) =>
      FarmModel(
        id: id,
        name: params.name,
        latitude: params.latitude,
        longitude: params.longitude,
        cropTypes: params.cropTypes,
        ownerId: ownerId,
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'cropTypes': cropTypes,
        'ownerId': ownerId,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
