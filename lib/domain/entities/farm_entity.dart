import 'package:equatable/equatable.dart';

class FarmEntity extends Equatable {
  final String? id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> cropTypes;
  final String ownerId;
  final DateTime createdAt;

  const FarmEntity({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.cropTypes,
    required this.ownerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        cropTypes,
        ownerId,
        createdAt,
      ];
}
