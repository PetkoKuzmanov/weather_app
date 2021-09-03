import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CurrentForecastWeather {
  final List<CurrentForecastWeatherData> currentForecastWeatherDataList;
}