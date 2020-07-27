part of health;

/// A [HealthDataPoint] object corresponds to a data point captures from GoogleFit or Apple HealthKit
class HealthDataPoint {
  num _value;
  String _unit;
  int _dateFrom;
  int _dateTo;
  String _dataType;
  String _platform;
  String _uuid;

  HealthDataPoint._(this._value, this._unit, this._dateFrom, this._dateTo,
      this._dataType, this._platform);

  HealthDataPoint._fromJson(Map<String, dynamic> json) {
    try {
      _value = json['value'];
      _unit = json['unit'];
      _dateFrom = json['date_from'];
      _dateTo = json['date_to'];
      _dataType = json['data_type'];
      _platform = json['platform_type'];

      /// If on Android, generate UUID from device ID concatenated with
      /// the data point as a string
      if (Platform.isAndroid) {
        String s = json['device_id'] + json.toString();
        String id = Uuid().v5(Uuid.NAMESPACE_URL, s);
        _uuid = id;
      }
      /// If on iOS, the UUID is already provided by the HealthKit API
      else {
        _uuid = json['uuid'];
      }
    } catch (error) {
      print(error);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['unit'] = this.unit;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['data_type'] = this.dataType;
    data['platform_type'] = this.platform;
    data['uuid'] = this.uuid;
    return data;
  }

  String toString() => '${this.runtimeType} - '
      'value: $value, '
      'unit: $unit, '
      'date_from: $dateFrom, '
      'dateFrom: $dateFrom, '
      'dateTo: $dateTo, '
      'dataType: $dataType, '
      'uuid: $uuid, '
      'platform: $platform';

  num get value => _value;

  String get unit => _unit;

  DateTime get dateFrom => DateTime.fromMillisecondsSinceEpoch(_dateFrom);

  DateTime get dateTo => DateTime.fromMillisecondsSinceEpoch(_dateTo);

  String get dataType => _dataType;

  String get platform => _platform;

  String get uuid => _uuid;


}
