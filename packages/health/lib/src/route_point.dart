part of '../health.dart';

/// A [RoutePoint] object stores various metrics of a route location.
///
///  * [longitude] - The longitude of the location.
///  * [latitude] - The latitude of the location.
///  * [altitude] - The altitude of the location.
///  * [timestamp] - The timestamp of the location.
///  * [horizontalAccuracy] - The horizontal accuracy of the location.
///  * [verticalAccuracy] - The vertical accuracy of the location.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class RoutePoint {
  /// The longitude of the location.
  double longitude;

  /// The latitude of the location.
  double latitude;

  /// The altitude of the location.
  double altitude;

  /// The timestamp of the location.
  int timestamp;

  /// The horizontal accuracy of the location.
  double? horizontalAccuracy;

  /// The vertical accuracy of the location.
  double? verticalAccuracy;

  RoutePoint({
    required this.longitude,
    required this.latitude,
    required this.altitude,
    required this.timestamp,
    this.horizontalAccuracy,
    this.verticalAccuracy,
  });

  /// Create a [RoutePoint] from json.
  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      _$RoutePointFromJson(json);

  /// Convert this [RoutePoint] to json.
  Map<String, dynamic> toJson() => _$RoutePointToJson(this);

  @override
  String toString() => '$runtimeType - '
      'longitude: $longitude'
      'latitude: $latitude, '
      'altitude: $altitude, '
      'timestamp: $timestamp, '
      'horizontalAccuracy: $horizontalAccuracy, '
      'verticalAccuracy: $verticalAccuracy';
}
