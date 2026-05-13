import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/get_cached_farms_usecase.dart';
import '../../../domain/usecases/get_farms_usecase.dart';
import 'farm_list_state.dart';

class FarmListCubit extends Cubit<FarmListState> {
  final GetFarmsUseCase _getFarms;
  final GetCachedFarmsUseCase _getCachedFarms;
  final AuthRepository _auth;

  FarmListCubit({
    required GetFarmsUseCase getFarms,
    required GetCachedFarmsUseCase getCachedFarms,
    required AuthRepository auth,
  })  : _getFarms = getFarms,
        _getCachedFarms = getCachedFarms,
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
    emit(state.copyWith(status: FarmListStatus.loading, fromCache: false));
    try {
      // Step 1: try Firestore — saves to cache on success.
      final farms = await _getFarms(uid);
      emit(state.copyWith(
        status: FarmListStatus.loaded,
        farms: farms,
        fromCache: false,
      ));
    } catch (_) {
      // Step 2: Firestore unreachable — serve last cached snapshot.
      final cached = await _getCachedFarms(uid);
      if (cached != null) {
        emit(state.copyWith(
          status: FarmListStatus.loaded,
          farms: cached,
          fromCache: true,
        ));
      } else {
        emit(state.copyWith(
          status: FarmListStatus.failure,
          errorMessage: 'No connection and no cached data',
        ));
      }
    }
  }

  Future<void> refresh() => loadFarms();
}
