// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobility_features.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MobilityContext _$MobilityContextFromJson(Map<String, dynamic> json) =>
    MobilityContext()
      ..timestamp = json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String)
      ..date =
          json['date'] == null ? null : DateTime.parse(json['date'] as String)
      ..numberOfStops = (json['numberOfStops'] as num?)?.toInt()
      ..numberOfMoves = (json['numberOfMoves'] as num?)?.toInt()
      ..numberOfSignificantPlaces =
          (json['numberOfSignificantPlaces'] as num?)?.toInt()
      ..locationVariance = (json['locationVariance'] as num?)?.toDouble()
      ..entropy = (json['entropy'] as num?)?.toDouble()
      ..normalizedEntropy = (json['normalizedEntropy'] as num?)?.toDouble()
      ..homeStay = (json['homeStay'] as num?)?.toDouble()
      ..distanceTraveled = (json['distanceTraveled'] as num?)?.toDouble();

Map<String, dynamic> _$MobilityContextToJson(MobilityContext instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('timestamp', instance.timestamp?.toIso8601String());
  writeNotNull('date', instance.date?.toIso8601String());
  writeNotNull('numberOfStops', instance.numberOfStops);
  writeNotNull('numberOfMoves', instance.numberOfMoves);
  writeNotNull('numberOfSignificantPlaces', instance.numberOfSignificantPlaces);
  writeNotNull('locationVariance', instance.locationVariance);
  writeNotNull('entropy', instance.entropy);
  writeNotNull('normalizedEntropy', instance.normalizedEntropy);
  writeNotNull('homeStay', instance.homeStay);
  writeNotNull('distanceTraveled', instance.distanceTraveled);
  return val;
}

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) => GeoLocation(
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$GeoLocationToJson(GeoLocation instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['latitude'] = instance.latitude;
  val['longitude'] = instance.longitude;
  return val;
}

LocationSample _$LocationSampleFromJson(Map<String, dynamic> json) =>
    LocationSample(
      GeoLocation.fromJson(json['geoLocation'] as Map<String, dynamic>),
      DateTime.parse(json['dateTime'] as String),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$LocationSampleToJson(LocationSample instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['dateTime'] = instance.dateTime.toIso8601String();
  val['geoLocation'] = instance.geoLocation.toJson();
  return val;
}

Stop _$StopFromJson(Map<String, dynamic> json) => Stop(
      GeoLocation.fromJson(json['geoLocation'] as Map<String, dynamic>),
      DateTime.parse(json['arrival'] as String),
      DateTime.parse(json['departure'] as String),
      (json['placeId'] as num?)?.toInt() ?? -1,
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$StopToJson(Stop instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['geoLocation'] = instance.geoLocation.toJson();
  val['placeId'] = instance.placeId;
  val['arrival'] = instance.arrival.toIso8601String();
  val['departure'] = instance.departure.toIso8601String();
  return val;
}

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
      (json['id'] as num).toInt(),
      (json['stops'] as List<dynamic>)
          .map((e) => Stop.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$PlaceToJson(Place instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['id'] = instance.id;
  val['stops'] = instance.stops.map((e) => e.toJson()).toList();
  return val;
}

Move _$MoveFromJson(Map<String, dynamic> json) => Move(
      Stop.fromJson(json['stopFrom'] as Map<String, dynamic>),
      Stop.fromJson(json['stopTo'] as Map<String, dynamic>),
      (json['distance'] as num?)?.toDouble(),
    )..$type = json['__type'] as String?;

Map<String, dynamic> _$MoveToJson(Move instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__type', instance.$type);
  val['stopFrom'] = instance.stopFrom.toJson();
  val['stopTo'] = instance.stopTo.toJson();
  writeNotNull('distance', instance.distance);
  return val;
}
