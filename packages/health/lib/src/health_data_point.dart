part of health;

/// A [HealthDataPoint] object corresponds to a data point captures from GoogleFit or Apple HealthKit
class HealthDataPoint {
  num _value;
  HealthDataType _type;
  HealthDataUnit _unit;
  DateTime _dateFrom;
  DateTime _dateTo;
  PlatformType _platform;
  String _deviceId;

  HealthDataPoint._(this._value, this._type, this._unit, this._dateFrom,
      this._dateTo, this._platform, this._deviceId);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['unit'] = this.unit;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['data_type'] = this.type;
    data['platform_type'] = this.platform;
    return data;
  }

  String toString() => '${this.runtimeType} - '
      'value: $value, '
      'unit: $unit, '
      'date_from: $dateFrom, '
      'dateFrom: $dateFrom, '
      'dateTo: $dateTo, '
      'dataType: $type,'
      'platform: $platform';

  num get value => _value;

  DateTime get dateFrom => _dateFrom;

  DateTime get dateTo => _dateTo;

  HealthDataType get type => _type;

  HealthDataUnit get unit => _unit;

  PlatformType get platform => _platform;

  String get typeString => _enumToString(_type);

  String get unitString => _enumToString(_unit);

  String get deviceId => _deviceId;

  /// Equals (==) operator overload
  bool operator ==(Object o) {
    return o is HealthDataPoint &&
        this.value == o.value &&
        this.unit == o.unit &&
        this.dateFrom == o.dateFrom &&
        this.dateTo == o.dateTo &&
        this.type == o.type &&
        this.platform == o.platform &&
        this.deviceId == o.deviceId;
  }

  /// Override required due to overriding (==) operator
  @override
  // TODO: implement hashCode
  int get hashCode => toJson().hashCode;


}
