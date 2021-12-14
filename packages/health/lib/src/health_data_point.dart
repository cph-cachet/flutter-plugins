part of health;

/// A [HealthDataPoint] object corresponds to a data point captures from
/// GoogleFit or Apple HealthKit
class HealthDataPoint {
  num _value;
  HealthDataType _type;
  HealthDataUnit _unit;
  DateTime _dateFrom;
  DateTime _dateTo;
  PlatformType _platform;
  String _deviceId;
  String _sourceId;
  String _sourceName;

  num? _totalEnergyBurned;
  num? _totalDistance;
  int? _workoutType;

  HealthDataPoint(
      this._value,
      this._type,
      this._unit,
      this._dateFrom,
      this._dateTo,
      this._platform,
      this._deviceId,
      this._sourceId,
      this._sourceName) {
    // set the value to minutes rather than the category
    // returned by the native API
    if (type == HealthDataType.MINDFULNESS ||
        type == HealthDataType.SLEEP_IN_BED ||
        type == HealthDataType.SLEEP_ASLEEP ||
        type == HealthDataType.SLEEP_AWAKE) {
      this._value = _convertMinutes();
    }
  }

  HealthDataPoint.forWorkout(
      this._value,
      this._type,
      this._unit,
      this._dateFrom,
      this._dateTo,
      this._platform,
      this._deviceId,
      this._sourceId,
      this._sourceName,
      this._workoutType,
      this._totalDistance,
      this._totalEnergyBurned,
      ) {
    //only used for workouts
  }

  double _convertMinutes() {
    int ms = dateTo.millisecondsSinceEpoch - dateFrom.millisecondsSinceEpoch;
    return ms / (1000 * 60);
  }

  /// Converts a json object to the [HealthDataPoint]
  factory HealthDataPoint.fromJson(json) => HealthDataPoint(
      json['value'],
      HealthDataTypeJsonValue.keys.toList()[
          HealthDataTypeJsonValue.values.toList().indexOf(json['data_type'])],
      HealthDataUnitJsonValue.keys.toList()[
          HealthDataUnitJsonValue.values.toList().indexOf(json['unit'])],
      DateTime.parse(json['date_from']),
      DateTime.parse(json['date_to']),
      PlatformTypeJsonValue.keys.toList()[
          PlatformTypeJsonValue.values.toList().indexOf(json['platform_type'])],
      json['platform_type'],
      json['source_id'],
      json['source_name']);

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'value': value,
        'data_type': HealthDataTypeJsonValue[type],
        'unit': HealthDataUnitJsonValue[unit],
        'date_from': DateFormat('yyyy-MM-dd HH:mm:ss').format(dateFrom),
        'date_to': DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTo),
        'platform_type': PlatformTypeJsonValue[platform],
        'device_id': deviceId,
        'source_id': sourceId,
        'source_name': sourceName
      };

  /// Converts the [HealthDataPoint] to a string
  String toString() => '${this.runtimeType} - '
      'value: $value, '
      'unit: $unit, '
      'dateFrom: $dateFrom, '
      'dateTo: $dateTo, '
      'dataType: $type,'
      'platform: $platform'
      'sourceId: $sourceId,'
      'sourceName: $sourceName,';

  /// Get the quantity value of the data point
  num get value => _value;

  /// Get the start of the datetime interval
  DateTime get dateFrom => _dateFrom;

  /// Get the end of the datetime interval
  DateTime get dateTo => _dateTo;

  /// Get the type of the data point
  HealthDataType get type => _type;

  /// Get the unit of the data point
  HealthDataUnit get unit => _unit;

  /// Get the software platform of the data point
  /// (i.e. Android or iOS)
  PlatformType get platform => _platform;

  /// Get the data point type as a string
  String get typeString => _enumToString(_type);

  /// Get the data point unit as a string
  String get unitString => _enumToString(_unit);

  /// Get the id of the device from which
  /// the data point was extracted
  String get deviceId => _deviceId;

  /// Get the id of the source from which
  /// the data point was extracted
  String get sourceId => _sourceId;

  /// Get the name of the source from which
  /// the data point was extracted
  String get sourceName => _sourceName;

  //For workouts these three fields are populated
  /// For workout data points what was the total distance travelled
  num get totalDistance => _totalDistance ?? 0;

  /// For workout data points what was the total energy burned
  num get totalEnergyBurned => _totalEnergyBurned ?? 0;

  /// For workout data points what was the workout type (iOS HealthKit HKWorkoutActivityType)
  int get workoutType => _workoutType ?? 0;


  /// An equals (==) operator for comparing two data points
  /// This makes it possible to remove duplicate data points.
  @override
  bool operator ==(Object o) {
    return o is HealthDataPoint &&
        this.value == o.value &&
        this.unit == o.unit &&
        this.dateFrom == o.dateFrom &&
        this.dateTo == o.dateTo &&
        this.type == o.type &&
        this.platform == o.platform &&
        this.deviceId == o.deviceId &&
        this.sourceId == o.sourceId &&
        this.sourceName == o.sourceName &&
        this.workoutType == o.workoutType &&
        this.totalEnergyBurned == o.totalEnergyBurned &&
        this.totalDistance == o.totalDistance;
  }

  /// Override required due to overriding the '==' operator
  @override
  int get hashCode => toJson().hashCode;
}
