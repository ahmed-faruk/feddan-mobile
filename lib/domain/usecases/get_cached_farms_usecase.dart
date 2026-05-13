import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

class GetCachedFarmsUseCase {
  final FarmRepository _repository;
  const GetCachedFarmsUseCase(this._repository);

  Future<List<FarmEntity>?> call(String ownerId) =>
      _repository.getCachedFarms(ownerId);
}
