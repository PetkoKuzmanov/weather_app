import 'package:json_annotation/json_annotation.dart';

import 'WeatherForecast.dart';

@JsonSerializable()
class City {
    final String name;
    final double latitude;
    final double longitude;
    WeatherForecast weatherForecast;

}