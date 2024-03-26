part of health;

/// A [HealthDataPoint] object corresponds to a data point capture from
/// GoogleFit or Apple HealthKit with a [HealthValue] as value.
class HealthDataPoint {
  HealthValue _value;
  HealthDataType _type;
  HealthDataUnit _unit;
  DateTime _dateFrom;
  DateTime _dateTo;
  PlatformType _platform;
  String _deviceId;
  String _sourceId;
  String _sourceName;
  bool? _isManualEntry;
  WorkoutSummary? _workoutSummary;

  HealthDataPoint(
    this._value,
    this._type,
    this._unit,
    this._dateFrom,
    this._dateTo,
    this._platform,
    this._deviceId,
    this._sourceId,
    this._sourceName,
    this._isManualEntry,
    this._workoutSummary,
  ) {
    // set the value to minutes rather than the category
    // returned by the native API
    if (type == HealthDataType.MINDFULNESS ||
        type == HealthDataType.HEADACHE_UNSPECIFIED ||
        type == HealthDataType.HEADACHE_NOT_PRESENT ||
        type == HealthDataType.HEADACHE_MILD ||
        type == HealthDataType.HEADACHE_MODERATE ||
        type == HealthDataType.HEADACHE_SEVERE ||
        type == HealthDataType.SLEEP_IN_BED ||
        type == HealthDataType.SLEEP_ASLEEP ||
        type == HealthDataType.SLEEP_AWAKE ||
        type == HealthDataType.SLEEP_DEEP ||
        type == HealthDataType.SLEEP_LIGHT ||
        type == HealthDataType.SLEEP_REM ||
        type == HealthDataType.SLEEP_OUT_OF_BED) {
      this._value = _convertMinutes();
    }
  }

  /// Converts dateTo - dateFrom to minutes.
  NumericHealthValue _convertMinutes() {
    int ms = dateTo.millisecondsSinceEpoch - dateFrom.millisecondsSinceEpoch;
    return NumericHealthValue(ms / (1000 * 60));
  }

  /// Converts a json object to the [HealthDataPoint]
  factory HealthDataPoint.fromJson(json) {
    HealthValue healthValue;
    if (json['data_type'] == 'AUDIOGRAM') {
      healthValue = AudiogramHealthValue.fromJson(json['value']);
    } else if (json['data_type'] == 'WORKOUT') {
      healthValue = WorkoutHealthValue.fromJson(json['value']);
    } else {
      healthValue = NumericHealthValue.fromJson(json['value']);
    }

    return HealthDataPoint(
      healthValue,
      HealthDataType.values
          .firstWhere((element) => element.name == json['data_type']),
      HealthDataUnit.values
          .firstWhere((element) => element.name == json['unit']),
      DateTime.parse(json['date_from']),
      DateTime.parse(json['date_to']),
      PlatformTypeJsonValue.keys.toList()[
          PlatformTypeJsonValue.values.toList().indexOf(json['platform_type'])],
      json['device_id'],
      json['source_id'],
      json['source_name'],
      json['is_manual_entry'],
      WorkoutSummary.fromJson(json['workout_summary']),
    );
  }

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'value': value.toJson(),
        'data_type': type.name,
        'unit': unit.name,
        'date_from': dateFrom.toIso8601String(),
        'date_to': dateTo.toIso8601String(),
        'platform_type': PlatformTypeJsonValue[platform],
        'device_id': deviceId,
        'source_id': sourceId,
        'source_name': sourceName,
        'is_manual_entry': isManualEntry,
        'workout_summary': workoutSummary?.toJson(),
      };

  @override
  String toString() => """${this.runtimeType} -
    value: ${value.toString()},
    unit: ${unit.name},
    dateFrom: $dateFrom,
    dateTo: $dateTo,
    dataType: ${type.name},
    platform: $platform,
    deviceId: $deviceId,
    sourceId: $sourceId,
    sourceName: $sourceName
    isManualEntry: $isManualEntry
    workoutSummary: ${workoutSummary?.toString()}""";

  /// The quantity value of the data point
  HealthValue get value => _value;

  /// The start of the time interval
  DateTime get dateFrom => _dateFrom;

  /// The end of the time interval
  DateTime get dateTo => _dateTo;

  /// The type of the data point
  HealthDataType get type => _type;

  /// The unit of the data point
  HealthDataUnit get unit => _unit;

  /// The software platform of the data point
  PlatformType get platform => _platform;

  /// The data point type as a string
  String get typeString => _type.name;

  /// The data point unit as a string
  String get unitString => _unit.name;

  /// The id of the device from which the data point was fetched.
  String get deviceId => _deviceId;

  /// The id of the source from which the data point was fetched.
  String get sourceId => _sourceId;

  /// The name of the source from which the data point was fetched.
  String get sourceName => _sourceName;

  /// The user entered state of the data point.
  bool? get isManualEntry => _isManualEntry;

  /// The summary of the workout data point.
  WorkoutSummary? get workoutSummary => _workoutSummary;

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
        this.isManualEntry == o.isManualEntry;
  }

  @override
  int get hashCode => Object.hash(value, unit, dateFrom, dateTo, type, platform,
      deviceId, sourceId, sourceName);
}
