import '../repositories/farm_repository.dart';

class UpdateFarmUseCase {
  final FarmRepository _repository;
  const UpdateFarmUseCase(this._repository);

  Future<void> call({
    required String farmId,
    required CreateFarmParams params,
  }) =>
      _repository.updateFarm(farmId, params);
}
