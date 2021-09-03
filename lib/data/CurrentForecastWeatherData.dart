import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CurrentForecastWeatherData {
  final int id;
  final String main;
  final String description;
  final String icon;

  CurrentForecastWeatherData(
      {required this.id,
      required this.main,
      required this.description,
      required this.icon});

  factory CurrentForecastWeatherData.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

CurrentForecastWeatherData _$PersonFromJson(Map<String, dynamic> json) => CurrentForecastWeatherData(
  id: json['id'] as int,
  main: json['main'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
);

Map<String, dynamic> _$PersonToJson(CurrentForecastWeatherData instance) => <String, dynamic>{
  'id': instance.id,
  'main': instance.main,
  'description': instance.description,
  'icon': instance.icon,
};