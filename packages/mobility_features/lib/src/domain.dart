part of '../mobility_features.dart';

const int HOURS_IN_A_DAY = 24;

/// Interface representing a geo location.
abstract interface class GeoSpatial {
  GeoLocation get geoLocation;
}

/// Interface for timestamped entities.
abstract interface class Timestamped {
  DateTime get dateTime;
}

/// Utility class for calculating distances.
class Distance {
  static double fromGeoSpatial(GeoSpatial a, GeoSpatial b) {
    return fromList([a.geoLocation.latitude, a.geoLocation.longitude],
        [b.geoLocation.latitude, b.geoLocation.longitude]);
  }

  static double fromList(List<double?> p1, List<double?> p2) {
    double lat1 = p1[0]!.radiansFromDegrees;
    double lon1 = p1[1]!.radiansFromDegrees;
    double lat2 = p2[0]!.radiansFromDegrees;
    double lon2 = p2[1]!.radiansFromDegrees;
    double earthRadius = 6378137.0; // WGS84 major axis
    double distance = 2 *
        earthRadius *
        asin(sqrt(pow(sin(lat2 - lat1) / 2, 2) +
            cos(lat1) * cos(lat2) * pow(sin(lon2 - lon1) / 2, 2)));

    return distance;
  }
}

/// A [GeoLocation] object contains a latitude and longitude
/// and represents a 2D spatial coordinates
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class GeoLocation extends Serializable implements GeoSpatial {
  double latitude, longitude;

  GeoLocation(this.latitude, this.longitude);

  @override
  GeoLocation get geoLocation => this;

  @override
  Function get fromJsonFunction => _$GeoLocationFromJson;
  factory GeoLocation.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson<GeoLocation>(json);

  @override
  Map<String, dynamic> toJson() => _$GeoLocationToJson(this);

  @override
  String toString() => '($latitude, $longitude)';
}

/// A [LocationSample] holds a 2D [GeoLocation] spatial data point
/// as well as a [DateTime] value s.t. it may be temporally ordered
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class LocationSample extends Serializable implements GeoSpatial, Timestamped {
  @override
  DateTime dateTime;
  @override
  GeoLocation geoLocation;

  LocationSample(this.geoLocation, this.dateTime);

  double? get latitude => geoLocation.latitude;
  double? get longitude => geoLocation.longitude;

  LocationSample addNoise() {
    double lat = geoLocation.latitude * 1.000001;
    double lon = geoLocation.longitude * 1.000001;
    return LocationSample(GeoLocation(lat, lon), dateTime);
  }

  @override
  Function get fromJsonFunction => _$LocationSampleFromJson;
  factory LocationSample.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson<LocationSample>(json);

  @override
  Map<String, dynamic> toJson() => _$LocationSampleToJson(this);

  @override
  String toString() => '($latitude, $longitude) @ $dateTime';
}

/// A [Stop] represents a cluster of [LocationSample] which were 'close' to each other
/// wrt. to Time and 2D space, in a period of little- to no movement.
/// A [Stop] has an assigned [placeId] which links it to a [Place].
/// At initialization a stop will be assigned to the 'Noise' place (with id -1),
/// and only after all places have been identified will a [Place] be assigned.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Stop extends Serializable implements GeoSpatial, Timestamped {
  @override
  GeoLocation geoLocation;
  int placeId = -1;
  DateTime arrival, departure;

  Stop(this.geoLocation, this.arrival, this.departure, [int placeId = -1]);

  /// Construct stop from point cloud
  factory Stop.fromLocationSamples(List<LocationSample> locationSamples,
      [int placeId = -1]) {
    // Calculate center
    GeoLocation center = _computeCentroid(locationSamples);
    return Stop(center, locationSamples.first.dateTime,
        locationSamples.last.dateTime, placeId);
  }

  @override
  DateTime get dateTime => arrival;

  List<double> get hourSlots {
    int startHour = arrival.hour;
    int endHour = departure.hour;

    List<double> hours = List<double>.filled(HOURS_IN_A_DAY, 0.0);

    // Start and end should be on the same date!
    if (departure.midnight == arrival.midnight) {
      // If arrived and departed within same hour
      if (startHour == endHour) {
        hours[startHour] = (departure.minute - arrival.minute) / 60.0;
      }

      // Otherwise if the stop has overlap in hours
      else {
        // Start
        hours[startHour] = 1.0 - arrival.minute / 60.0;

        // In between
        for (int hour = startHour + 1; hour < endHour; hour++) {
          hours[hour] = 1.0;
        }

        // Departure
        hours[endHour] = departure.minute / 60.0;
      }
    }
    return hours;
  }

  Duration get duration => Duration(
      milliseconds:
          departure.millisecondsSinceEpoch - arrival.millisecondsSinceEpoch);

  @override
  Function get fromJsonFunction => _$StopFromJson;
  factory Stop.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson<Stop>(json);

  @override
  Map<String, dynamic> toJson() => _$StopToJson(this);

  @override
  String toString() =>
      'Stop at place $placeId, (${geoLocation.toString()}) [$arrival - $departure] (Duration: $duration) ';
}

/// A [Place] is a cluster of [Stop]s found by the DBSCAN algorithm
/// https://www.aaai.org/Papers/KDD/1996/KDD96-037.pdf
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Place extends Serializable {
  final int id;
  final List<Stop> stops;
  GeoLocation? _geoLocation;

  Place(this.id, this.stops);

  Duration get duration => stops.map((s) => s.duration).reduce((a, b) => a + b);

  Duration durationForDate(DateTime? d) => stops
      .where((s) => s.arrival.midnight == d)
      .map((s) => s.duration)
      .fold(const Duration(), (a, b) => a + b);

  GeoLocation? get geoLocation => _geoLocation ??= _computeCentroid(stops);

  @override
  Function get fromJsonFunction => _$PlaceFromJson;
  factory Place.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson<Place>(json);
  @override
  Map<String, dynamic> toJson() => _$PlaceToJson(this);

  @override
  String toString() =>
      'Place ID: $id, at ${geoLocation.toString()} ($duration)';
}

/// A [Move] is a transfer from one [Stop] to another.
/// A set of features can be derived from this such as the haversine distance between
/// the stops, the duration of the move, and thereby also the average travel speed.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Move extends Serializable implements Timestamped {
  Stop stopFrom, stopTo;

  /// The haversine distance through all the samples between the two stops
  double? distance;

  Move(this.stopFrom, this.stopTo, [this.distance]);

  /// Create a Move with a path of samples between two stops
  factory Move.fromPath(Stop a, Stop b, List<LocationSample> path) {
    double d = 0.0;
    for (int i = 0; i < path.length - 1; i++) {
      d += Distance.fromGeoSpatial(path[i], path[i + 1]);
    }
    return Move(a, b, d);
  }

  /// Create a Move with a straight line between two stops
  // ignore: unused_element
  factory Move.fromStops(Stop a, Stop b, {double? distance}) {
    /// Distance can be overridden. If it was not then it should be computed
    distance ??= Distance.fromGeoSpatial(a, b);
    return Move(a, b, distance);
  }

  /// The duration of the move in milliseconds
  Duration get duration => Duration(
      milliseconds: stopTo.arrival.millisecondsSinceEpoch -
          stopFrom.departure.millisecondsSinceEpoch);

  /// The average speed when moving between the two places (m/s)
  double get meanSpeed => distance! / duration.inSeconds.toDouble();

  int? get placeFrom => stopFrom.placeId;

  int? get placeTo => stopTo.placeId;

  @override
  DateTime get dateTime => stopFrom.arrival;

  @override
  Function get fromJsonFunction => _$MoveFromJson;
  factory Move.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson<Move>(json);

  @override
  Map<String, dynamic> toJson() => _$MoveToJson(this);

  @override
  String toString() =>
      'Move (Place ${stopFrom.placeId} [${stopFrom.dateTime}] -> Place ${stopTo.placeId} [${stopTo.dateTime}]) ($duration) (${distance!.toInt()} meters)';
}

class HourMatrix {
  List<List<double>> matrix;
  late int _numberOfPlaces;

  int get numberOfPlaces => _numberOfPlaces;

  HourMatrix(this.matrix) {
    _numberOfPlaces = matrix.first.length;
  }

  factory HourMatrix.fromStops(List<Stop> stops, int numPlaces) {
    // Init 2d matrix with 24 rows and cols equal to number of places
    List<List<double>> matrix = List.generate(
        HOURS_IN_A_DAY, (_) => List<double>.filled(numPlaces, 0.0));

    for (int j = 0; j < numPlaces; j++) {
      List<Stop> stopsAtPlace = stops.where((s) => (s.placeId) == j).toList();

      for (Stop s in stopsAtPlace) {
        // For each hour of the day, add the hours from the StopRow to the matrix
        for (int i = 0; i < HOURS_IN_A_DAY; i++) {
          matrix[i][j] += s.hourSlots[i];
        }
      }
    }
    return HourMatrix(matrix);
  }

  // ignore: unused_element
  factory HourMatrix.routineMatrix(List<HourMatrix> matrices) {
    int nDays = matrices.length;
    int nPlaces = matrices.first.matrix.first.length;
    List<List<double>> avg = zeroMatrix(HOURS_IN_A_DAY, nPlaces);

    for (HourMatrix m in matrices) {
      for (int i = 0; i < HOURS_IN_A_DAY; i++) {
        for (int j = 0; j < nPlaces; j++) {
          avg[i][j] += m.matrix[i][j] / nDays;
        }
      }
    }
    return HourMatrix(avg);
  }

  /// Features
  int get homePlaceId {
    int startHour = 0, endHour = 6;

    List<double> hourSpentAtPlace = List.filled(numberOfPlaces, 0.0);

    for (int placeId = 0; placeId < numberOfPlaces; placeId++) {
      for (int hour = startHour; hour < endHour; hour++) {
        hourSpentAtPlace[placeId] += matrix[hour][placeId];
      }
    }
    double timeSpentAtNight = hourSpentAtPlace.fold(0.0, (a, b) => a + b);
    if (timeSpentAtNight > 0) {
      return argmaxDouble(hourSpentAtPlace);
    }
    return -1;
  }

  double get sum {
    double s = 0.0;
    for (int i = 0; i < HOURS_IN_A_DAY; i++) {
      for (int j = 0; j < numberOfPlaces; j++) {
        s += matrix[i][j];
      }
    }
    return s;
  }

  /// Calculates the error between two matrices
  double computeOverlap(HourMatrix other) {
    /// Check that dimensions match
    assert(other.matrix.length == HOURS_IN_A_DAY &&
        other.matrix.first.length == matrix.first.length);

    double maxOverlap = min(sum, other.sum);

    if (maxOverlap == 0.0) return -1.0;

    /// Cumulative error between the two matrices
    double overlap = 0.0;
    //
    for (int i = 0; i < HOURS_IN_A_DAY; i++) {
      for (int j = 0; j < numberOfPlaces; j++) {
        /// If overlap in time-place matrix,
        /// add the overlap to the total overlap.
        /// The overlap is equal to the minimum of the two quantities
        if (matrix[i][j] >= 0.0 && other.matrix[i][j] >= 0.0) {
          overlap += min(matrix[i][j], other.matrix[i][j]);
        }
      }
    }

    /// Compute average error by dividing by the number of total entries
    return overlap / maxOverlap;
  }

  @override
  String toString() {
    String s = '\n';
    s += 'Home place ID: $homePlaceId\n';
    s += 'Matrix\t\t';
    for (int p = 0; p < numberOfPlaces; p++) {
      s += 'Place $p\t\t';
    }
    s += '\n';
    for (int hour = 0; hour < HOURS_IN_A_DAY; hour++) {
      s += 'Hour ${hour.toString().padLeft(2, '0')}\t\t';

      for (double e in matrix[hour]) {
        s += '${e.toStringAsFixed(3)}\t\t';
      }
      s += '\n';
    }
    return s;
  }
}
