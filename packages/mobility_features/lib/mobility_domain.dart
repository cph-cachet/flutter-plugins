part of mobility_features;

const int HOURS_IN_A_DAY = 24;

/// Abstract class to enforce functions
/// to serialize and deserialize an object
abstract class _Serializable {
  Map<String, dynamic> _toJson();

  _Serializable._fromJson(Map<String, dynamic> json);
}

/// Simple abstract class to let the compiler know that an object
/// implementing this class has a location
abstract class _Geospatial {
  GeoPosition get geoPosition;
}

class Distance {
  static double fromGeospatial(_Geospatial a, _Geospatial b) {
    return fromList([a.geoPosition._latitude, a.geoPosition._longitude],
        [b.geoPosition._latitude, b.geoPosition._longitude]);
  }

  static double fromList(List<double> p1, List<double> p2) {
    double lat1 = p1[0].radiansFromDegrees;
    double lon1 = p1[1].radiansFromDegrees;
    double lat2 = p2[0].radiansFromDegrees;
    double lon2 = p2[1].radiansFromDegrees;
    double earthRadius = 6378137.0; // WGS84 major axis
    double distance = 2 *
        earthRadius *
        asin(sqrt(pow(sin(lat2 - lat1) / 2, 2) +
            cos(lat1) * cos(lat2) * pow(sin(lon2 - lon1) / 2, 2)));

    return distance;
  }
}

/// A [GeoPosition] object contains a latitude and longitude
/// and represents a 2D spatial coordinates
class GeoPosition implements _Serializable, _Geospatial {
  double _latitude;
  double _longitude;

  GeoPosition(this._latitude, this._longitude);

  factory GeoPosition.fromJson(Map<String, dynamic> x) {
    num lat = x['latitude'] as double;
    num lon = x['longitude'] as double;
    return GeoPosition(lat, lon);
  }

  GeoPosition get geoPosition => this;

  double get latitude => _latitude;

  double get longitude => _longitude;

  Map<String, dynamic> _toJson() =>
      {"latitude": latitude, "longitude": longitude};

  @override
  String toString() {
    return '($_latitude, $_longitude)';
  }
}

/// A [LocationSample] holds a 2D [GeoPosition] spatial data point
/// as well as a [DateTime] value s.t. it may be temporally ordered
class LocationSample implements _Serializable, _Geospatial {
  GeoPosition _geoPosition;
  DateTime _datetime;

  LocationSample(this._geoPosition, this._datetime);

  GeoPosition get geoPosition => _geoPosition;

  DateTime get datetime => _datetime;

  Map<String, dynamic> _toJson() => {
        "geo_position": geoPosition._toJson(),
        "datetime": json.encode(datetime.millisecondsSinceEpoch)
      };

  factory LocationSample._fromJson(Map<String, dynamic> json) {
    /// Parse, i.e. perform type check
    GeoPosition loc = GeoPosition.fromJson(json['geo_position']);
    int millis = int.parse(json['datetime']);
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return LocationSample(loc, dt);
  }

  @override
  String toString() {
    return '$_geoPosition @ $_datetime';
  }
}

/// A [Stop] represents a cluster of [LocationSample] which were 'close' to eachother
/// wrt. to Time and 2D space, in a period of little- to no movement.
/// A [Stop] has an assigned [placeId] which links it to a [Place].
/// At initialization a stop will be assigned to the 'Noise' place (with id -1),
/// and only after all places have been identified will a [Place] be assigned.
class Stop implements _Serializable, _Geospatial {
  GeoPosition _geoPosition;
  int placeId;
  DateTime _arrival, _departure;

  Stop._(this._geoPosition, this._arrival, this._departure, {this.placeId = -1});

  /// Construct stop from point cloud
  factory Stop._fromLocationSamples(List<LocationSample> locationSamples,
      {int placeId = -1}) {
    /// Calculate center
    GeoPosition center = _computeCentroid(locationSamples);
    return Stop._(center, locationSamples.first.datetime, locationSamples.last.datetime,
        placeId: placeId);
  }

  GeoPosition get geoPosition => _geoPosition;

  DateTime get departure => _departure;

  DateTime get arrival => _arrival;

  List<double> get hourSlots {
    /// Start and end should be on the same date!
    int startHour = arrival.hour;
    int endHour = departure.hour;

    if (departure.midnight != arrival.midnight) {
      throw Exception(
          'Arrival and Departure should be on the same date, but was not! $this');
    }

    List<double> hours = List<double>.filled(HOURS_IN_A_DAY, 0.0);

    /// If arrived and departed within same hour
    if (startHour == endHour) {
      hours[startHour] = (departure.minute - arrival.minute) / 60.0;
    }

    /// Otherwise if the stop has overlap in hours
    else {
      /// Start
      hours[startHour] = 1.0 - arrival.minute / 60.0;

      /// In between
      for (int hour = startHour + 1; hour < endHour; hour++) {
        hours[hour] = 1.0;
      }

      /// Departure
      hours[endHour] = departure.minute / 60.0;
    }
    return hours;
  }

  Duration get duration => Duration(
      milliseconds:
          departure.millisecondsSinceEpoch - arrival.millisecondsSinceEpoch);

  Map<String, dynamic> _toJson() => {
        "centroid": geoPosition._toJson(),
        "place_id": placeId,
        "arrival": arrival.millisecondsSinceEpoch,
        "departure": departure.millisecondsSinceEpoch
      };

  factory Stop._fromJson(Map<String, dynamic> json) {
    return Stop._(
        GeoPosition.fromJson(json['centroid']),
        DateTime.fromMillisecondsSinceEpoch(json['arrival']),
        DateTime.fromMillisecondsSinceEpoch(json['departure']),
        placeId: json['place_id']);
  }

  @override
  String toString() {
    return 'Stop at place $placeId,  (${_geoPosition.toString()}) [$arrival - $departure] ($duration) ';
  }
}

/// A [Place] is a cluster of [Stop]s found by the DBSCAN algorithm
/// https://www.aaai.org/Papers/KDD/1996/KDD96-037.pdf
class Place {
  int _id;
  List<Stop> _stops;
  GeoPosition _geoPosition;

  Place._(this._id, this._stops);

  Duration get duration =>
      _stops.map((s) => s.duration).reduce((a, b) => a + b);

  Duration durationForDate(DateTime d) => _stops
      .where((s) => s.arrival.midnight == d)
      .map((s) => s.duration)
      .fold(Duration(), (a, b) => a + b);

  GeoPosition get geoPosition {
    if (_geoPosition == null) {
      _geoPosition = _computeCentroid(_stops);
    }
    return _geoPosition;
  }

  int get id => _id;

  @override
  String toString() {
    return 'Place ID: $_id, at ${geoPosition.toString()} ($duration)';
  }
}

/// A [Move] is a transfer from one [Stop] to another.
/// A set of features can be derived from this such as the haversine distance between
/// the stops, the duration of the move, and thereby also the average travel speed.
class Move implements _Serializable {
  Stop _stopFrom, _stopTo;
  double _distance;

  Move._(this._stopFrom, this._stopTo, this._distance);

  factory Move._fromPath(Stop a, Stop b, List<LocationSample> path) {
    double d = _computePathDistance(path);
    return Move._(a, b, d);
  }

  /// The haversine distance through all the samples between the two stops
  double get distance => _distance;

  static double _computePathDistance(List<LocationSample> path) {
    double d = 0.0;
    for (int i = 0; i < path.length - 1; i++) {
      d += Distance.fromGeospatial(path[i], path[i + 1]);
    }
    return d;
  }

  /// The duration of the move in milliseconds
  Duration get duration => Duration(
      milliseconds: _stopTo.arrival.millisecondsSinceEpoch -
          _stopFrom.departure.millisecondsSinceEpoch);

  /// The average speed when moving between the two places (m/s)
  double get meanSpeed => distance / duration.inSeconds.toDouble();

  int get placeFrom => _stopFrom.placeId;

  int get placeTo => _stopTo.placeId;

  Stop get stopFrom => _stopFrom;

  Stop get stopTo => _stopTo;

  Map<String, dynamic> _toJson() => {
        "stop_from": _stopFrom._toJson(),
        "stop_to": _stopTo._toJson(),
        "distance": _distance
      };

  factory Move._fromJson(Map<String, dynamic> _json) {
    return Move._(Stop._fromJson(_json["stop_from"]),
        Stop._fromJson(_json["stop_to"]), _json["distance"]);
  }

  @override
  String toString() {
    return '''Move:
    FROM: $_stopFrom
    TO:   $_stopTo
    Duration: $duration
    Distance: $distance
    ''';
  }
}

class _HourMatrix {
  List<List<double>> _matrix;
  int _numberOfPlaces;


  _HourMatrix(this._matrix) {
    _numberOfPlaces = _matrix.first.length;
  }

  factory _HourMatrix.fromStops(List<Stop> stops, int numPlaces) {
    /// Init 2d matrix with 24 rows and cols equal to number of places
    List<List<double>> matrix = new List.generate(
        HOURS_IN_A_DAY, (_) => new List<double>.filled(numPlaces, 0.0));

    for (int j = 0; j < numPlaces; j++) {
      List<Stop> stopsAtPlace = stops.where((s) => (s.placeId) == j).toList();

      for (Stop s in stopsAtPlace) {
        /// For each hour of the day, add the hours from the StopRow to the matrix
        for (int i = 0; i < HOURS_IN_A_DAY; i++) {
          matrix[i][j] += s.hourSlots[i];
        }
      }
    }
    return _HourMatrix(matrix);
  }

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
        s += this.matrix[i][j];
      }
    }
    return s;
  }

  /// Calculates the error between two matrices
  double computeOverlap(_HourMatrix other) {
    /// Check that dimensions match
    assert(other.matrix.length == HOURS_IN_A_DAY &&
        other.matrix.first.length == _matrix.first.length);

    double maxOverlap = min(this.sum, other.sum);

    if (maxOverlap == 0.0) return -1.0;

    /// Cumulative error between the two matrices
    double overlap = 0.0;
    //
    for (int i = 0; i < HOURS_IN_A_DAY; i++) {
      for (int j = 0; j < _numberOfPlaces; j++) {
        /// If overlap in time-place matrix,
        /// add the overlap to the total overlap.
        /// The overlap is equal to the minimum of the two quantities
        if (this.matrix[i][j] >= 0.0 && other.matrix[i][j] >= 0.0) {
          overlap += min(this.matrix[i][j], other.matrix[i][j]);
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
