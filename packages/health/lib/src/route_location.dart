part of '../health.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class RouteLocation {
  double longitude;
  double latitude;
  double altitude;
  int timestamp;

  RouteLocation({
    required this.longitude,
    required this.latitude,
    required this.altitude,
    required this.timestamp,
  });

  factory RouteLocation.fromJson(Map<String, dynamic> json) =>
      _$RouteLocationFromJson(json);

  Map<String, dynamic> toJson() => _$RouteLocationToJson(this);

  @override
  String toString() => '$runtimeType - '
      'longitude: $longitude'
      'latitude: $latitude, '
      'altitude: $altitude, '
      'timestamp: $timestamp, ';
}
