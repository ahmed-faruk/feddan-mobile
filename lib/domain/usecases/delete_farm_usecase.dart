import '../repositories/farm_repository.dart';

class DeleteFarmUseCase {
  final FarmRepository _repository;
  const DeleteFarmUseCase(this._repository);

  Future<void> call(String farmId) => _repository.deleteFarm(farmId);
}
