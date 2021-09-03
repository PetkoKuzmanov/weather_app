import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class WeatherForecast {

    CurrentForecast current;
    HourlyForecast hourly;
    DailyForecast daily;

}