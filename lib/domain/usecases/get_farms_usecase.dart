import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

class GetFarmsUseCase {
  final FarmRepository _repository;
  const GetFarmsUseCase(this._repository);

  Future<List<FarmEntity>> call(String ownerId) =>
      _repository.getFarms(ownerId);
}
