part of health;

/// A [HealthDataPoint] object corresponds to a data point captures from
/// GoogleFit or Apple HealthKit.
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

  @override
  String toString() => '${this.runtimeType} - '
      'value: $value, '
      'unit: $unit, '
      'dateFrom: $dateFrom, '
      'dateTo: $dateTo, '
      'dataType: $type, '
      'platform: $platform, '
      'sourceId: $sourceId, '
      'sourceName: $sourceName';

  /// The quantity value of the data point
  num get value => _value;

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
  String get typeString => _enumToString(_type);

  /// The data point unit as a string
  String get unitString => _enumToString(_unit);

  /// The id of the device from which the data point was fetched.
  String get deviceId => _deviceId;

  /// The id of the source from which the data point was fetched.
  String get sourceId => _sourceId;

  /// The name of the source from which the data point was fetched.
  String get sourceName => _sourceName;

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
        this.sourceName == o.sourceName;
  }

  @override
  int get hashCode => toJson().hashCode;
}
