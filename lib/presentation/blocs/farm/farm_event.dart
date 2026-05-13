part of 'farm_bloc.dart';

sealed class FarmEvent extends Equatable {
  const FarmEvent();

  @override
  List<Object?> get props => [];
}

final class FarmNameChanged extends FarmEvent {
  final String name;
  const FarmNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

final class FarmLocationRequested extends FarmEvent {
  const FarmLocationRequested();
}

final class FarmLocationPinChanged extends FarmEvent {
  final double latitude;
  final double longitude;
  const FarmLocationPinChanged(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

final class FarmCropToggled extends FarmEvent {
  final String cropType;
  const FarmCropToggled(this.cropType);

  @override
  List<Object?> get props => [cropType];
}

final class FarmPlantingDateChanged extends FarmEvent {
  final DateTime date;
  const FarmPlantingDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

final class FarmSaveRequested extends FarmEvent {
  const FarmSaveRequested();
}

final class FarmDeleteRequested extends FarmEvent {
  const FarmDeleteRequested();
}
