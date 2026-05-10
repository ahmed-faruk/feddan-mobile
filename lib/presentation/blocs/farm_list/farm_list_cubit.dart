import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/usecases/get_farms_usecase.dart';
import 'farm_list_state.dart';

class FarmListCubit extends Cubit<FarmListState> {
  final GetFarmsUseCase _getFarms;
  final AuthRepositoryImpl _auth;

  FarmListCubit({
    required GetFarmsUseCase getFarms,
    required AuthRepositoryImpl auth,
  })  : _getFarms = getFarms,
        _auth = auth,
        super(const FarmListState());

  Future<void> loadFarms() async {
    final uid = _auth.currentUserId;
    if (uid == null) {
      emit(state.copyWith(
        status: FarmListStatus.failure,
        errorMessage: 'Not authenticated',
      ));
      return;
    }
    emit(state.copyWith(status: FarmListStatus.loading));
    try {
      final farms = await _getFarms(uid);
      emit(state.copyWith(status: FarmListStatus.loaded, farms: farms));
    } catch (e) {
      emit(state.copyWith(
        status: FarmListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() => loadFarms();
}
