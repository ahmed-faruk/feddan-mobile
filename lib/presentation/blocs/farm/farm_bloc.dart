import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/farm_entity.dart';
import '../../../domain/repositories/farm_repository.dart';
import '../../../domain/usecases/create_farm_usecase.dart';
import '../../../domain/usecases/delete_farm_usecase.dart';
import '../../../domain/usecases/update_farm_usecase.dart';

part 'farm_event.dart';
part 'farm_state.dart';

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  final CreateFarmUseCase _createFarm;
  final UpdateFarmUseCase _updateFarm;
  final DeleteFarmUseCase _deleteFarm;

  FarmBloc({
    required CreateFarmUseCase createFarm,
    required UpdateFarmUseCase updateFarm,
    required DeleteFarmUseCase deleteFarm,
    FarmEntity? existingFarm,
  })  : _createFarm = createFarm,
        _updateFarm = updateFarm,
        _deleteFarm = deleteFarm,
        super(
          existingFarm != null
              ? FarmState(
                  editingFarmId: existingFarm.id,
                  name: existingFarm.name,
                  latitude: existingFarm.latitude,
                  longitude: existingFarm.longitude,
                  selectedCrops: List<String>.from(existingFarm.cropTypes),
                  plantingDate: existingFarm.plantingDate,
                )
              : const FarmState(),
        ) {
    on<FarmNameChanged>(_onNameChanged);
    on<FarmLocationRequested>(_onLocationRequested);
    on<FarmLocationPinChanged>(_onPinChanged);
    on<FarmCropToggled>(_onCropToggled);
    on<FarmPlantingDateChanged>(_onPlantingDateChanged);
    on<FarmSaveRequested>(_onSaveRequested);
    on<FarmDeleteRequested>(_onDeleteRequested);
  }

  void _onNameChanged(FarmNameChanged event, Emitter<FarmState> emit) =>
      emit(state.copyWith(name: event.name));

  void _onPinChanged(FarmLocationPinChanged event, Emitter<FarmState> emit) =>
      emit(state.copyWith(
          latitude: event.latitude, longitude: event.longitude));

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
    final params = CreateFarmParams(
      name: state.name,
      latitude: state.latitude!,
      longitude: state.longitude!,
      cropTypes: state.selectedCrops,
      plantingDate: state.plantingDate!,
    );
    try {
      if (state.isEditMode) {
        await _updateFarm(farmId: state.editingFarmId!, params: params);
      } else {
        await _createFarm(params);
      }
      emit(state.copyWith(status: FarmStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FarmStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteRequested(
    FarmDeleteRequested event,
    Emitter<FarmState> emit,
  ) async {
    if (!state.isEditMode) return;
    emit(state.copyWith(status: FarmStatus.deleting));
    try {
      await _deleteFarm(state.editingFarmId!);
      emit(state.copyWith(status: FarmStatus.deleted));
    } catch (e) {
      emit(state.copyWith(
        status: FarmStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
