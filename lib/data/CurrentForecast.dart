import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CurrentForecast {
  final int dt;
  final double temp;
  final double feels_like;
  final int pressure;
  final int humidity;
  final double uvi;
  final double clouds;
  final int visibility;
  final double wind_speed;
  final int wind_deg;

  CurrentForecastWeather weather;
}