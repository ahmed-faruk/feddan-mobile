part of 'farm_bloc.dart';

enum FarmStatus { initial, locating, saving, success, deleting, deleted, failure }

final class FarmState extends Equatable {
  final FarmStatus status;
  final String name;
  final double? latitude;
  final double? longitude;
  final List<String> selectedCrops;
  final DateTime? plantingDate;
  final String? errorMessage;
  // Non-null when opened for editing an existing farm.
  final String? editingFarmId;

  const FarmState({
    this.status = FarmStatus.initial,
    this.name = '',
    this.latitude,
    this.longitude,
    this.selectedCrops = const [],
    this.plantingDate,
    this.errorMessage,
    this.editingFarmId,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get isEditMode => editingFarmId != null;
  bool get isValid =>
      name.trim().isNotEmpty &&
      hasLocation &&
      selectedCrops.isNotEmpty &&
      plantingDate != null;

  FarmState copyWith({
    FarmStatus? status,
    String? name,
    double? latitude,
    double? longitude,
    List<String>? selectedCrops,
    DateTime? plantingDate,
    String? errorMessage,
    String? editingFarmId,
  }) =>
      FarmState(
        status: status ?? this.status,
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        selectedCrops: selectedCrops ?? this.selectedCrops,
        plantingDate: plantingDate ?? this.plantingDate,
        errorMessage: errorMessage ?? this.errorMessage,
        editingFarmId: editingFarmId ?? this.editingFarmId,
      );

  @override
  List<Object?> get props =>
      [status, name, latitude, longitude, selectedCrops, plantingDate, errorMessage, editingFarmId];
}
