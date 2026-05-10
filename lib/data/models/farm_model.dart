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
    required super.plantingDate,
    required super.ownerId,
    required super.createdAt,
  });

  factory FarmModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return FarmModel(
      id: doc.id,
      name: d['name'] as String,
      latitude: (d['latitude'] as num).toDouble(),
      longitude: (d['longitude'] as num).toDouble(),
      cropTypes: List<String>.from(d['cropTypes'] as List),
      plantingDate: (d['plantingDate'] as Timestamp).toDate(),
      ownerId: d['ownerId'] as String,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  factory FarmModel.fromParams(String id, CreateFarmParams p, String ownerId) =>
      FarmModel(
        id: id,
        name: p.name,
        latitude: p.latitude,
        longitude: p.longitude,
        cropTypes: p.cropTypes,
        plantingDate: p.plantingDate,
        ownerId: ownerId,
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'cropTypes': cropTypes,
        'plantingDate': Timestamp.fromDate(plantingDate),
        'ownerId': ownerId,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
