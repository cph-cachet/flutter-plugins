part of health;

/// Main class for the Plugin
class Health {
  static const MethodChannel _channel = const MethodChannel('flutter_health');

  static _PlatformType _platformType =
      Platform.isAndroid ? _PlatformType.ANDROID : _PlatformType.IOS;

  /// Check if a given data type is available on the platform
  static bool isDataTypeAvailable(HealthDataType dataType) =>
      _platformType == _PlatformType.ANDROID
          ? _dataTypesAndroid.contains(dataType)
          : _dataTypesIOS.contains(dataType);

  /// Request access to GoogleFit/Apple HealthKit
  static Future<bool> requestAuthorization(List<HealthDataType> healthTypes) async {
    List<String> types = healthTypes.map((t) => _enumToString(t)).toList();

    final bool isAuthorized =
        await _channel.invokeMethod('requestAuthorization', {'types': types});
    return isAuthorized;
  }

  // Calculate the BMI using the last observed height and weight values.
  static Future<List<HealthDataPoint>> _androidBodyMassIndex(
      DateTime startDate, DateTime endDate) async {
    List<HealthDataPoint> heights =
        await getHealthDataFromType(startDate, endDate, HealthDataType.HEIGHT);
    List<HealthDataPoint> weights =
        await getHealthDataFromType(startDate, endDate, HealthDataType.WEIGHT);

    num bmiValue =
        weights.last.value / (heights.last.value * heights.last.value);

    HealthDataType dataType = HealthDataType.BODY_MASS_INDEX;
    HealthDataUnit unit = _dataTypeToUnit[dataType];

    HealthDataPoint bmi = HealthDataPoint._(
        bmiValue,
        _enumToString(unit),
        startDate.millisecond,
        endDate.millisecond,
        _enumToString(dataType),
        _PlatformType.ANDROID.toString());

    return [bmi];
  }

  static HealthDataPoint _processDataPoint(var dataPoint,
      HealthDataType dataType, HealthDataUnit unit, String deviceId) {
    // Set the platform_type and data_type fields
    dataPoint["platform_type"] = _platformType.toString();

    // Set the [DataType] fields
    dataPoint["data_type"] = _enumToString(dataType);

    // Overwrite unit with a Flutter Unit
    dataPoint["unit"] = _enumToString(unit);

    // Set the device ID
    dataPoint["device_id"] = deviceId;

    // Convert to JSON, and then to HealthData object
    return HealthDataPoint._fromJson(Map<String, dynamic>.from(dataPoint));
  }

  // Main function for fetching health data
  static Future<List<HealthDataPoint>> getHealthDataFromType(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw new _HealthDataNotAvailableException(dataType, _platformType);
    }

    // If BodyMassIndex is requested on Android, calculate this manually in Dart
    else if (dataType == HealthDataType.BODY_MASS_INDEX &&
        _platformType == _PlatformType.ANDROID) {
      return _androidBodyMassIndex(startDate, endDate);
    }

    // Set parameters for method channel request
    Map<String, dynamic> args = {
      'dataTypeKey': _enumToString(dataType),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };

    String deviceId = await DeviceId.getID;

    List<HealthDataPoint> healthData = new List();
    HealthDataUnit unit = _dataTypeToUnit[dataType];

    try {
      List fetchedDataPoints = await _channel.invokeMethod('getData', args);
      healthData = fetchedDataPoints
          .map((e) => _processDataPoint(e, dataType, unit, deviceId))
          .toList();
    } catch (error) {
      print(error);
    }
    return healthData;
  }

  static List<HealthDataPoint> removeDuplicates(List<HealthDataPoint> points) {
    Set<String> seen = Set();
    List<HealthDataPoint> set = [];

    /// Avoid duplicates
    for (HealthDataPoint p in points) {
      if (!seen.contains(p.uuid)) {
        seen.add(p.uuid);
        set.add(p);
      }
    }
    return set;
  }
}
