part of mobility_features;

/// Daily mobility context.
/// All Stops and Moves should be on the same date.
/// Places are all places for which the duration
/// on the given data is greater than 0
class MobilityContext {
  List<Stop> _stops;
  List<Place> _allPlaces, _places;

  List<Stop> get stops => _stops;
  List<Move> _moves;
  DateTime _timestamp, date;
  _HourMatrix _hourMatrix;

  /// Features
  int _numberOfPlaces;
  double _locationVariance,
      _entropy,
      _normalizedEntropy,
      _homeStay,
      _distanceTravelled,
      _routineIndex;
  List<MobilityContext> contexts;

  /// Private constructor, cannot be instantiated from outside
  MobilityContext._(this._stops, this._allPlaces, this._moves,
      {this.contexts, this.date}) {
    _timestamp = DateTime.now();
    date = date ?? _timestamp.midnight;
  }

  get timestamp => _timestamp;

  double get routineIndex {
    if (_routineIndex == null) {
      _routineIndex = _calculateRoutineIndex();
    }
    return _routineIndex;
  }

  /// Get places today
  List<Place> get places {
    if (_places == null) {
      _places = _allPlaces
          .where((p) => p.durationForDate(date).inMilliseconds > 0)
          .toList();
    }
    return _places;
  }

  /// Hour matrix for the day
  /// Uses the number of allPlaces since matrices have to match other days
  _HourMatrix get _hm {
    if (_hourMatrix == null) {
      _hourMatrix = _HourMatrix.fromStops(_stops, _allPlaces.length);
    }
    return _hourMatrix;
  }

  /// Number of Places today
  int get numberOfPlaces {
    if (_numberOfPlaces == null) {
      _numberOfPlaces = _calculateNumberOfPlaces();
    }
    return _numberOfPlaces;
  }

  /// Home Stay Percentage today
  /// A scalar between 0 and 1, i.e. from 0% to 100%
  double get homeStay {
    if (_homeStay == null) {
      _homeStay = _calculateHomeStay();
    }
    return _homeStay;
  }

  /// Location Variance today
  double get locationVariance {
    if (_locationVariance == null) {
      _locationVariance = _calculateLocationVariance();
    }
    return _locationVariance;
  }

  /// Entropy
  /// High entropy: Time is spent evenly among all places
  /// Low  entropy: Time is mainly spent at a few of the places
  double get entropy {
    if (_entropy == null) {
      _entropy = _calculateEntropy();
    }
    return _entropy;
  }

  /// Normalized entropy,
  /// a scalar between 0 and 1
  double get normalizedEntropy {
    if (_normalizedEntropy == null) {
      _normalizedEntropy = _calculateNormalizedEntropy();
    }
    return _normalizedEntropy;
  }

  /// Distance travelled today, in meters
  double get distanceTravelled {
    if (_distanceTravelled == null) {
      _distanceTravelled = _calculateDistanceTravelled();
    }
    return _distanceTravelled;
  }

  /// Private number of places calculation
  int _calculateNumberOfPlaces() {
    return places.length;
  }

  /// Private home stay calculation
  double _calculateHomeStay() {
    // Latest known sample time
    DateTime latestTime = _stops.last.departure;

    // Total time elapsed from midnight until the last stop
    int totalTime = latestTime.millisecondsSinceEpoch -
        latestTime.midnight.millisecondsSinceEpoch;

    // Find todays home id, if no home exists today return -1.0
    _HourMatrix hm = this._hm;
    if (hm.homePlaceId == -1) {
      return -1.0;
    }

    int homeTime = stops
        .where((s) => s.placeId == hm.homePlaceId)
        .map((s) => s.duration.inMilliseconds)
        .fold(0, (a, b) => a + b);

    return homeTime.toDouble() / totalTime.toDouble();
  }

  /// Private location variance calculation
  double _calculateLocationVariance() {
    /// Require at least 2 observations
    if (_stops.length < 2) {
      return 0.0;
    }
    double latStd = Stats.fromData(_stops.map((s) => (s.geoPosition.latitude)))
        .standardDeviation;
    double lonStd = Stats.fromData(_stops.map((s) => (s.geoPosition.longitude)))
        .standardDeviation;
    return log(latStd * latStd + lonStd * lonStd + 1);
  }

  double _calculateEntropy() {
    // If no places were visited return -1.0
    if (places.isEmpty) {
      return -1.0;
    }
    // The Entropy is zero when one outcome is certain to occur.
    else if (places.length < 2) {
      return 0.0;
    }
    // Calculate time spent at different places
    List<Duration> durations =
        places.map((p) => p.durationForDate(date)).toList();

    Duration totalTimeSpent = durations.fold(Duration(), (a, b) => a + b);

    List<double> distribution = durations
        .map((d) => (d.inMilliseconds.toDouble() /
            totalTimeSpent.inMilliseconds.toDouble()))
        .toList();

    return -distribution.map((p) => p * log(p)).reduce((a, b) => (a + b));
  }

  /// Private normalized entropy calculation
  double _calculateNormalizedEntropy() {
    if (numberOfPlaces < 2) {
      return 0.0;
    }
    return entropy / log(numberOfPlaces);
  }

  /// Private distance travelled calculation
  double _calculateDistanceTravelled() {
    return _moves.map((m) => (m.distance)).fold(0.0, (a, b) => a + b);
  }

  /// Routine index (overlap) calculation
  double _calculateRoutineIndex() {
    // We require at least 2 days to compute the routine index
    if (contexts == null) {
      return -1.0;
    } else if (contexts.isEmpty) {
      return -1.0;
    }

    /// Compute the HourMatrix for each context that is older
    List<_HourMatrix> matrices = contexts
        .where((c) => c.date.isBefore(this.date))
        .map((c) => c._hm)
        .toList();

    /// Compute the 'average day' from the matrices
    _HourMatrix routine = _HourMatrix.routineMatrix(matrices);

    /// Compute the overlap between the 'average day' and today
    return this._hm.computeOverlap(routine);
  }

  List<Place> get allPlaces => _allPlaces;

  List<Move> get moves => _moves;

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "timestamp": timestamp.toIso8601String(),
        "num_of_places": numberOfPlaces,
        "entropy": entropy,
        "normalized_entropy": normalizedEntropy,
        "home_stay": homeStay,
        "distance_travelled": distanceTravelled,
        "routine_index": routineIndex,
      };
}

class ContextGenerator {
  static const String LOCATION_SAMPLES = 'location_samples',
      STOPS = 'stops',
      MOVES = 'moves';

  static Future<File> _file(String type) async {
    bool isMobile = Platform.isAndroid || Platform.isIOS;

    /// If on a mobile device, use the path_provider plugin to access the
    /// file system
    String path;
    if (isMobile) {
      path = (await getApplicationDocumentsDirectory()).path;
    } else {
      path = 'test/data';
    }
    return new File('$path/$type.json');
  }

  static Future<_MobilitySerializer<LocationSample>>
  get _locationSampleSerializer async =>
      _MobilitySerializer<LocationSample>._(await _file(LOCATION_SAMPLES));


  static Future<void> saveSamples(List<LocationSample> samples) async {
    (await _locationSampleSerializer).save(samples);
  }

  static Future<List<LocationSample>> loadSamples() async {
    List<LocationSample> samples = await (await _locationSampleSerializer).load();
    return samples;
  }

  static Future<MobilityContext> generate(
      {bool usePriorContexts: false, DateTime today}) async {
    /// Init serializers
    _MobilitySerializer<LocationSample> sampleSerializer =
        await _locationSampleSerializer;
    _MobilitySerializer<Stop> stopSerializer =
        _MobilitySerializer<Stop>._(await _file(STOPS));
    _MobilitySerializer<Move> moveSerializer =
        _MobilitySerializer<Move>._(await _file(MOVES));

    /// Load data from disk
    List<LocationSample> samplesToday = await sampleSerializer.load();

    // Define today as the midnight time
    today = today ?? DateTime.now();
    today = today.midnight;

    // Filter out old samples
    samplesToday = _filterSamples(samplesToday, today);

    // Filter out todays stops, and stops older than 28 days
    List<Stop> stopsHist = await stopSerializer.load();
    List<Move> movesHist = await moveSerializer.load();
    stopsHist = _stopsHistoric(stopsHist, today);
    movesHist = _movesHistoric(movesHist, today);

    /// Recompute stops and moves today and add them
    List<Stop> stopsToday = _findStops(samplesToday, today);
    List<Move> movesToday = _findMoves(samplesToday, stopsToday);

    List<Stop> stopsAll = stopsHist + stopsToday;
    List<Move> movesAll = movesHist + movesToday;

    /// Find places for the period
    List<Place> placesAll = _findPlaces(stopsAll);

    /// Save Stops and Moves to disk
    stopSerializer.flush();
    moveSerializer.flush();
    stopSerializer.save(stopsAll);
    moveSerializer.save(movesAll);

    /// Find prior contexts, if prior is not chosen just leave empty
    List<MobilityContext> priorContexts = [];

    /// If Prior is chosen, compute mobility contexts for each previous date.
    if (usePriorContexts) {
      Set<DateTime> dates = stopsHist.map((s) => s.arrival.midnight).toSet();
      for (DateTime date in dates) {
        List<Stop> stopsOnDate = _stopsForDate(stopsHist, date);
        List<Move> movesOnDate = _movesForDate(movesHist, date);
        MobilityContext mc =
            MobilityContext._(stopsOnDate, placesAll, movesOnDate, date: date);
        priorContexts.add(mc);
      }
    }

    return MobilityContext._(stopsToday, placesAll, movesToday,
        contexts: priorContexts, date: today);
  }

  static List<LocationSample> _filterSamples(
      List<LocationSample> X, DateTime date) {
    return X.where((x) => x.datetime.midnight == date).toList();
  }

  static List<Stop> _stopsForDate(List<Stop> stops, DateTime date) {
    return stops.where((x) => x.arrival.midnight == date).toList();
  }

  static List<Move> _movesForDate(List<Move> moves, DateTime date) {
    return moves.where((x) => x.stopFrom.arrival.midnight == date).toList();
  }

  static List<Stop> _stopsHistoric(List<Stop> stops, DateTime date) {
    DateTime fourWeeksPrior = date.subtract(Duration(days: 28));
    return stops
        .where((x) =>
            x.arrival.midnight.isBefore(date) &&
            x.arrival.midnight.isAfter(fourWeeksPrior))
        .toList();
  }

  static List<Move> _movesHistoric(List<Move> moves, DateTime date) {
    DateTime fourWeeksPrior = date.subtract(Duration(days: 28));
    return moves
        .where((x) =>
            x.stopFrom.arrival.midnight.isBefore(date) &&
            x.stopFrom.arrival.midnight.isAfter(fourWeeksPrior))
        .toList();
  }
}
