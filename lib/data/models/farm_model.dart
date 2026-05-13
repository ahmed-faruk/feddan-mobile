import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/farm_entity.dart';
import '../../domain/entities/weather_snapshot.dart';
import '../../domain/repositories/farm_repository.dart';

class FarmModel extends FarmEntity {
  const FarmModel({
    super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.cropTypes,
    required super.plantingDate,
    required super.ownerId,
    required super.createdAt,
    super.latestWeather,
  });

  factory FarmModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return FarmModel(
      id: doc.id,
      name: d['name'] as String,
      latitude: (d['latitude'] as num).toDouble(),
      longitude: (d['longitude'] as num).toDouble(),
      cropTypes: List<String>.from(d['cropTypes'] as List),
      plantingDate: (d['plantingDate'] as Timestamp).toDate(),
      ownerId: d['ownerId'] as String,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      latestWeather: _parseWeather(d['latestWeather'] as Map?),
    );
  }

  static WeatherSnapshot? _parseWeather(Map? w) {
    if (w == null) return null;
    try {
      return WeatherSnapshot(
        date: (w['date'] as Timestamp).toDate(),
        et0: (w['et0'] as num).toDouble(),
        rainfall: (w['rainfall'] as num).toDouble(),
        maxTempC: (w['maxTempC'] as num).toDouble(),
        minTempC: (w['minTempC'] as num).toDouble(),
        humidityPct: (w['humidityPct'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  factory FarmModel.fromParams(String id, CreateFarmParams p, String ownerId) =>
      FarmModel(
        id: id,
        name: p.name,
        latitude: p.latitude,
        longitude: p.longitude,
        cropTypes: p.cropTypes,
        plantingDate: p.plantingDate,
        ownerId: ownerId,
        createdAt: DateTime.now(),
      );

  // Used for Firestore writes — keeps Timestamp objects.
  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'cropTypes': cropTypes,
        'plantingDate': Timestamp.fromDate(plantingDate),
        'ownerId': ownerId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  // Used for Hive writes — pure JSON, no Firestore types.
  Map<String, dynamic> toHiveJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'cropTypes': cropTypes,
        'plantingDate': plantingDate.millisecondsSinceEpoch,
        'ownerId': ownerId,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'latestWeather': latestWeather != null
            ? _weatherToJson(latestWeather!)
            : null,
      };

  static Map<String, dynamic> _weatherToJson(WeatherSnapshot w) => {
        'date': w.date.millisecondsSinceEpoch,
        'et0': w.et0,
        'rainfall': w.rainfall,
        'maxTempC': w.maxTempC,
        'minTempC': w.minTempC,
        'humidityPct': w.humidityPct,
      };

  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
        id: json['id'] as String?,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        cropTypes: List<String>.from(json['cropTypes'] as List),
        plantingDate: DateTime.fromMillisecondsSinceEpoch(
            json['plantingDate'] as int),
        ownerId: json['ownerId'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            json['createdAt'] as int),
        latestWeather: json['latestWeather'] != null
            ? _parseWeatherFromJson(
                json['latestWeather'] as Map<String, dynamic>)
            : null,
      );

  static WeatherSnapshot _parseWeatherFromJson(Map<String, dynamic> w) =>
      WeatherSnapshot(
        date: DateTime.fromMillisecondsSinceEpoch(w['date'] as int),
        et0: (w['et0'] as num).toDouble(),
        rainfall: (w['rainfall'] as num).toDouble(),
        maxTempC: (w['maxTempC'] as num).toDouble(),
        minTempC: (w['minTempC'] as num).toDouble(),
        humidityPct: (w['humidityPct'] as num).toDouble(),
      );
}
