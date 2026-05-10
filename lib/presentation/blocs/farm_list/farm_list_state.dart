import 'package:equatable/equatable.dart';

import '../../../domain/entities/farm_entity.dart';

enum FarmListStatus { initial, loading, loaded, failure }

class FarmListState extends Equatable {
  final FarmListStatus status;
  final List<FarmEntity> farms;
  final String? errorMessage;

  const FarmListState({
    this.status = FarmListStatus.initial,
    this.farms = const [],
    this.errorMessage,
  });

  bool get hasFarms => farms.isNotEmpty;
  bool get isLoading => status == FarmListStatus.loading;

  List<String> get farmIds =>
      farms.where((f) => f.id != null).map((f) => f.id!).toList();

  FarmListState copyWith({
    FarmListStatus? status,
    List<FarmEntity>? farms,
    String? errorMessage,
  }) =>
      FarmListState(
        status: status ?? this.status,
        farms: farms ?? this.farms,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, farms, errorMessage];
}
