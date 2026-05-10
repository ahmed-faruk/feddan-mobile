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

final class FarmCropToggled extends FarmEvent {
  final String cropType;
  const FarmCropToggled(this.cropType);

  @override
  List<Object?> get props => [cropType];
}

final class FarmSaveRequested extends FarmEvent {
  const FarmSaveRequested();
}
