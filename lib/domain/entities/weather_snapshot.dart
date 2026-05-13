import 'package:equatable/equatable.dart';

class WeatherSnapshot extends Equatable {
  final DateTime date;
  final double et0;
  final double rainfall;
  final double maxTempC;
  final double minTempC;
  final double humidityPct;

  const WeatherSnapshot({
    required this.date,
    required this.et0,
    required this.rainfall,
    required this.maxTempC,
    required this.minTempC,
    required this.humidityPct,
  });

  @override
  List<Object?> get props =>
      [date, et0, rainfall, maxTempC, minTempC, humidityPct];
}
