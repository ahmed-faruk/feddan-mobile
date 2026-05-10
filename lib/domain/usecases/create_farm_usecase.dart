import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

class CreateFarmUseCase {
  final FarmRepository _repository;
  const CreateFarmUseCase(this._repository);

  Future<FarmEntity> call(CreateFarmParams params) =>
      _repository.createFarm(params);
}
