part of '../mobility_features.dart';

const int HOURS_IN_A_DAY = 24;
const String _LATITUDE = 'latitude',
    _LONGITUDE = 'longitude',
    _DATE_TIME = 'datetime',
    _ARRIVAL = 'arrival',
    _DEPARTURE = 'departure',
    _PLACE_ID = 'place_id',
    _STOP_FROM = 'stop_from',
    _STOP_TO = 'stop_to',
    _DISTANCE = 'distance',
    _GEO_LOCATION = 'geo_location';

/// Interface for JSON serialization.
abstract interface class Serializable {
  Map<String, dynamic> toJson();
  Serializable.fromJson(Map<String, dynamic> json);
}

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
class GeoLocation implements Serializable, GeoSpatial {
  late double _latitude;
  late double _longitude;

  GeoLocation(this._latitude, this._longitude);

  factory GeoLocation.fromJson(Map<String, dynamic> x) {
    num? lat = x[_LATITUDE] as double?;
    num? lon = x[_LONGITUDE] as double?;
    return GeoLocation(lat as double, lon as double);
  }

  double get latitude => _latitude;

  double get longitude => _longitude;

  @override
  GeoLocation get geoLocation => this;

  @override
  Map<String, dynamic> toJson() => {_LATITUDE: latitude, _LONGITUDE: longitude};

  @override
  String toString() => '($_latitude, $_longitude)';
}

/// A [LocationSample] holds a 2D [GeoLocation] spatial data point
/// as well as a [DateTime] value s.t. it may be temporally ordered
class LocationSample implements Serializable, GeoSpatial, Timestamped {
  DateTime _dateTime;
  GeoLocation _geoLocation;

  LocationSample(this._geoLocation, this._dateTime);

  @override
  DateTime get dateTime => _dateTime;

  @override
  GeoLocation get geoLocation => _geoLocation;

  double? get latitude => geoLocation.latitude;

  double? get longitude => geoLocation.longitude;

  @override
  Map<String, dynamic> toJson() => {
        _GEO_LOCATION: geoLocation.toJson(),
        _DATE_TIME: json.encode(dateTime.millisecondsSinceEpoch)
      };

  factory LocationSample.fromJson(Map<String, dynamic> json) {
    /// Parse, i.e. perform type check
    GeoLocation pos =
        GeoLocation.fromJson(json[_GEO_LOCATION] as Map<String, dynamic>);
    int millis = int.parse(json[_DATE_TIME] as String);
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return LocationSample(pos, dt);
  }

  LocationSample addNoise() {
    double lat = geoLocation.latitude * 1.000001;
    double lon = geoLocation.longitude * 1.000001;
    return LocationSample(GeoLocation(lat, lon), dateTime);
  }

  @override
  String toString() => '($latitude, $longitude) @ $_dateTime';
}

/// A [Stop] represents a cluster of [LocationSample] which were 'close' to each other
/// wrt. to Time and 2D space, in a period of little- to no movement.
/// A [Stop] has an assigned [placeId] which links it to a [Place].
/// At initialization a stop will be assigned to the 'Noise' place (with id -1),
/// and only after all places have been identified will a [Place] be assigned.
class Stop implements Serializable, GeoSpatial, Timestamped {
  GeoLocation _geoLocation;
  int _placeId = -1;
  DateTime _arrival, _departure;

  Stop(this._geoLocation, this._arrival, this._departure, [int _placeId = -1]);

  /// Construct stop from point cloud
  factory Stop.fromLocationSamples(List<LocationSample> locationSamples,
      [int placeId = -1]) {
    // Calculate center
    GeoLocation center = _computeCentroid(locationSamples);
    return Stop(center, locationSamples.first.dateTime,
        locationSamples.last.dateTime, placeId);
  }

  @override
  DateTime get dateTime => _arrival;

  @override
  GeoLocation get geoLocation => _geoLocation;

  DateTime get departure => _departure;

  DateTime get arrival => _arrival;

  int get placeId => _placeId;

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
  Map<String, dynamic> toJson() => {
        _GEO_LOCATION: geoLocation.toJson(),
        _PLACE_ID: placeId,
        _ARRIVAL: arrival.millisecondsSinceEpoch,
        _DEPARTURE: departure.millisecondsSinceEpoch
      };

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
      GeoLocation.fromJson(json[_GEO_LOCATION] as Map<String, dynamic>),
      DateTime.fromMillisecondsSinceEpoch(json[_ARRIVAL] as int),
      DateTime.fromMillisecondsSinceEpoch(json[_DEPARTURE] as int),
      json[_PLACE_ID] as int);

  @override
  String toString() =>
      'Stop at place $placeId, (${_geoLocation.toString()}) [$arrival - $departure] (Duration: $duration) ';
}

/// A [Place] is a cluster of [Stop]s found by the DBSCAN algorithm
/// https://www.aaai.org/Papers/KDD/1996/KDD96-037.pdf
class Place {
  final int _id;
  final List<Stop> _stops;
  GeoLocation? _geoLocation;

  Place(this._id, this._stops);

  Duration get duration =>
      _stops.map((s) => s.duration).reduce((a, b) => a + b);

  Duration durationForDate(DateTime? d) => _stops
      .where((s) => s.arrival.midnight == d)
      .map((s) => s.duration)
      .fold(const Duration(), (a, b) => a + b);

  int get id => _id;

  List<Stop> get stops => _stops;

  GeoLocation? get geoLocation => _geoLocation ??= _computeCentroid(_stops);

  @override
  String toString() =>
      'Place ID: $_id, at ${geoLocation.toString()} ($duration)';
}

/// A [Move] is a transfer from one [Stop] to another.
/// A set of features can be derived from this such as the haversine distance between
/// the stops, the duration of the move, and thereby also the average travel speed.
class Move implements Serializable, Timestamped {
  Stop stopFrom, stopTo;

  /// The haversine distance through all the samples between the two stops
  double? distance;

  Move(this.stopFrom, this.stopTo, this.distance);

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
  Map<String, dynamic> toJson() => {
        _STOP_FROM: stopFrom.toJson(),
        _STOP_TO: stopTo.toJson(),
        _DISTANCE: distance
      };

  factory Move.fromJson(Map<String, dynamic> json) => Move(
      Stop.fromJson(json[_STOP_FROM] as Map<String, dynamic>),
      Stop.fromJson(json[_STOP_TO] as Map<String, dynamic>),
      json[_DISTANCE] as double);

  @override
  String toString() =>
      'Move (Place ${stopFrom.placeId} [${stopFrom.dateTime}] -> Place ${stopTo.placeId} [${stopTo.dateTime}]) ($duration) (${distance!.toInt()} meters)';
}

class _HourMatrix {
  List<List<double>> _matrix;
  late int _numberOfPlaces;

  _HourMatrix(this._matrix) {
    _numberOfPlaces = _matrix.first.length;
  }

  factory _HourMatrix.fromStops(List<Stop> stops, int numPlaces) {
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
    return _HourMatrix(matrix);
  }

  // ignore: unused_element
  factory _HourMatrix.routineMatrix(List<_HourMatrix> matrices) {
    int nDays = matrices.length;
    int nPlaces = matrices.first.matrix.first.length;
    List<List<double>> avg = zeroMatrix(HOURS_IN_A_DAY, nPlaces);

    for (_HourMatrix m in matrices) {
      for (int i = 0; i < HOURS_IN_A_DAY; i++) {
        for (int j = 0; j < nPlaces; j++) {
          avg[i][j] += m.matrix[i][j] / nDays;
        }
      }
    }
    return _HourMatrix(avg);
  }

  List<List<double>> get matrix => _matrix;

  /// Features
  int get homePlaceId {
    int startHour = 0, endHour = 6;

    List<double> hourSpentAtPlace = List.filled(_numberOfPlaces, 0.0);

    for (int placeId = 0; placeId < _numberOfPlaces; placeId++) {
      for (int hour = startHour; hour < endHour; hour++) {
        hourSpentAtPlace[placeId] += _matrix[hour][placeId];
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
      for (int j = 0; j < _numberOfPlaces; j++) {
        s += matrix[i][j];
      }
    }
    return s;
  }

  /// Calculates the error between two matrices
  double computeOverlap(_HourMatrix other) {
    /// Check that dimensions match
    assert(other.matrix.length == HOURS_IN_A_DAY &&
        other.matrix.first.length == _matrix.first.length);

    double maxOverlap = min(sum, other.sum);

    if (maxOverlap == 0.0) return -1.0;

    /// Cumulative error between the two matrices
    double overlap = 0.0;
    //
    for (int i = 0; i < HOURS_IN_A_DAY; i++) {
      for (int j = 0; j < _numberOfPlaces; j++) {
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
    for (int p = 0; p < _numberOfPlaces; p++) {
      s += 'Place $p\t\t';
    }
    s += '\n';
    for (int hour = 0; hour < HOURS_IN_A_DAY; hour++) {
      s += 'Hour ${hour.toString().padLeft(2, '0')}\t\t';

      for (double e in _matrix[hour]) {
        s += '${e.toStringAsFixed(3)}\t\t';
      }
      s += '\n';
    }
    return s;
  }
}
