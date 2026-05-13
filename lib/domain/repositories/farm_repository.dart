import '../entities/farm_entity.dart';

class CreateFarmParams {
  final String name;
  final double latitude;
  final double longitude;
  final List<String> cropTypes;
  final DateTime plantingDate;

  const CreateFarmParams({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.cropTypes,
    required this.plantingDate,
  });
}

abstract class FarmRepository {
  Future<FarmEntity> createFarm(CreateFarmParams params);
  Future<void> updateFarm(String farmId, CreateFarmParams params);
  Future<void> deleteFarm(String farmId);
  Future<List<FarmEntity>> getFarms(String ownerId);
  /// Returns the last cached farm list for [ownerId], or null if no cache exists.
  Future<List<FarmEntity>?> getCachedFarms(String ownerId);
}
