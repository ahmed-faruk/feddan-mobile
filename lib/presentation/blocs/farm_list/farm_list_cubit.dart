import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_farms_usecase.dart';
import 'farm_list_state.dart';

class FarmListCubit extends Cubit<FarmListState> {
  final GetFarmsUseCase _getFarms;

  FarmListCubit({required GetFarmsUseCase getFarms})
      : _getFarms = getFarms,
        super(const FarmListState());

  Future<void> loadFarms(String ownerId) async {
    emit(state.copyWith(status: FarmListStatus.loading));
    try {
      final farms = await _getFarms(ownerId);
      emit(state.copyWith(status: FarmListStatus.loaded, farms: farms));
    } catch (e) {
      emit(state.copyWith(
        status: FarmListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh(String ownerId) => loadFarms(ownerId);
}
