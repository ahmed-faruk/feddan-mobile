import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/repositories/farm_repository.dart';
import '../../../domain/usecases/create_farm_usecase.dart';

part 'farm_event.dart';
part 'farm_state.dart';

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  final CreateFarmUseCase _createFarm;

  FarmBloc({required CreateFarmUseCase createFarm})
      : _createFarm = createFarm,
        super(const FarmState()) {
    on<FarmNameChanged>(_onNameChanged);
    on<FarmLocationRequested>(_onLocationRequested);
    on<FarmCropToggled>(_onCropToggled);
    on<FarmPlantingDateChanged>(_onPlantingDateChanged);
    on<FarmSaveRequested>(_onSaveRequested);
  }

  void _onNameChanged(FarmNameChanged event, Emitter<FarmState> emit) =>
      emit(state.copyWith(name: event.name));

  void _onPlantingDateChanged(
          FarmPlantingDateChanged event, Emitter<FarmState> emit) =>
      emit(state.copyWith(plantingDate: event.date));

  Future<void> _onLocationRequested(
    FarmLocationRequested event,
    Emitter<FarmState> emit,
  ) async {
    emit(state.copyWith(status: FarmStatus.locating));
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        emit(state.copyWith(
          status: FarmStatus.failure,
          errorMessage: 'تم رفض إذن الموقع — يرجى السماح من الإعدادات',
        ));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      emit(state.copyWith(
        status: FarmStatus.initial,
        latitude: pos.latitude,
        longitude: pos.longitude,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: FarmStatus.failure,
        errorMessage: 'فشل تحديد الموقع',
      ));
    }
  }

  void _onCropToggled(FarmCropToggled event, Emitter<FarmState> emit) {
    final crops = List<String>.from(state.selectedCrops);
    if (crops.contains(event.cropType)) {
      crops.remove(event.cropType);
    } else {
      crops.add(event.cropType);
    }
    emit(state.copyWith(selectedCrops: crops));
  }

  Future<void> _onSaveRequested(
    FarmSaveRequested event,
    Emitter<FarmState> emit,
  ) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FarmStatus.saving));
    try {
      await _createFarm(CreateFarmParams(
        name: state.name,
        latitude: state.latitude!,
        longitude: state.longitude!,
        cropTypes: state.selectedCrops,
        plantingDate: state.plantingDate!,
      ));
      emit(state.copyWith(status: FarmStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FarmStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
