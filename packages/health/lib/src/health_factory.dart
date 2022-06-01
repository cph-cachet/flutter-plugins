part of health;

/// Main class for the Plugin.
///
/// The plugin supports:
///
///  * handling permissions to access health data using the [hasPermissions],
///    [requestAuthorization], [revokePermissions] methods.
///  * reading health data using the [getHealthDataFromTypes] method.
///  * writing health data using the [writeHealthData] method.
///  * accessing total step counts using the [getTotalStepsInInterval] method.
///  * cleaning up dublicate data points via the [removeDuplicates] method.
class HealthFactory {
  static const MethodChannel _channel = MethodChannel('flutter_health');
  String? _deviceId;
  final _deviceInfo = DeviceInfoPlugin();

  static PlatformType _platformType =
      Platform.isAndroid ? PlatformType.ANDROID : PlatformType.IOS;

  /// Check if a given data type is available on the platform
  bool isDataTypeAvailable(HealthDataType dataType) =>
      _platformType == PlatformType.ANDROID
          ? _dataTypeKeysAndroid.contains(dataType)
          : _dataTypeKeysIOS.contains(dataType);

  /// Determines if the data types have been granted with the specified access rights.
  ///
  /// Returns:
  ///
  /// * true - if all of the data types have been granted with the specfied access rights.
  /// * false - if any of the data types has not been granted with the specified access right(s)
  /// * null - if it can not be determined if the data types have been granted with the specified access right(s).
  ///
  /// Parameters:
  ///
  /// * [types]  - List of [HealthDataType] whose permissions are to be checked.
  /// * [permissions] - Optional.
  ///   + If unspecified, this method checks if each HealthDataType in [types] has been granted READ access.
  ///   + If specified, this method checks if each [HealthDataType] in [types] has been granted with the access specified in its
  ///   corresponding entry in this list. The length of this list must be equal to that of [types].
  ///
  ///  Caveat:
  ///
  ///   As Apple HealthKit will not disclose if READ access has been granted for a data type due to privacy concern,
  ///   this method can only return null to represent an undertermined status, if it is called on iOS
  ///   with a READ or READ_WRITE access.
  ///
  ///   On Android, this function returns true or false, depending on whether the specified access right has been granted.
  static Future<bool?> hasPermissions(List<HealthDataType> types,
      {List<HealthDataAccess>? permissions}) async {
    if (permissions != null && permissions.length != types.length)
      throw ArgumentError(
          "The lists of types and permissions must be of same length.");

    final mTypes = List<HealthDataType>.from(types, growable: true);
    final mPermissions = permissions == null
        ? List<int>.filled(types.length, HealthDataAccess.READ.index,
            growable: true)
        : permissions.map((permission) => permission.index).toList();

    /// On Android, if BMI is requested, then also ask for weight and height
    if (_platformType == PlatformType.ANDROID) _handleBMI(mTypes, mPermissions);

    return await _channel.invokeMethod('hasPermissions', {
      "types": mTypes.map((type) => type.typeToString()).toList(),
      "permissions": mPermissions,
    });
  }

  /// Revoke permissions obtained earlier.
  ///
  /// Not supported on iOS and method does nothing.
  static Future<void> revokePermissions() async {
    return await _channel.invokeMethod('revokePermissions');
  }

  /// Requests permissions to access data types in Apple Health or Google Fit.
  ///
  /// Returns true if successful, false otherwise
  ///
  /// Parameters:
  ///
  /// * [types] - a list of [HealthDataType] which the permissions are requested for.
  /// * [permissions] - Optional.
  ///   + If unspecified, each [HealthDataType] in [types] is requested for READ [HealthDataAccess].
  ///   + If specified, each [HealthDataAccess] in this list is requested for its corresponding indexed
  ///   entry in [types]. In addition, the length of this list must be equal to that of [types].
  ///
  ///  Caveat:
  ///
  ///   As Apple HealthKit will not disclose if READ access has been granted for a data type due to privacy concern,
  ///   this method will return **true if the window asking for permission was showed to the user without errors**
  ///   if it is called on iOS with a READ or READ_WRITE access.
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    if (permissions != null && permissions.length != types.length) {
      throw ArgumentError(
          'The length of [types] must be same as that of [permissions].');
    }

    final mTypes = List<HealthDataType>.from(types, growable: true);
    final mPermissions = permissions == null
        ? List<int>.filled(types.length, HealthDataAccess.READ.index,
            growable: true)
        : permissions.map((permission) => permission.index).toList();

    // on Android, if BMI is requested, then also ask for weight and height
    if (_platformType == PlatformType.ANDROID) _handleBMI(mTypes, mPermissions);

    List<String> keys = mTypes.map((e) => _enumToString(e)).toList();
    final bool? isAuthorized = await _channel.invokeMethod(
        'requestAuthorization', {'types': keys, "permissions": mPermissions});
    return isAuthorized ?? false;
  }

  static void _handleBMI(List<HealthDataType> mTypes, List<int> mPermissions) {
    final index = mTypes.indexOf(HealthDataType.BODY_MASS_INDEX);

    if (index != -1 && _platformType == PlatformType.ANDROID) {
      if (!mTypes.contains(HealthDataType.WEIGHT)) {
        mTypes.add(HealthDataType.WEIGHT);
        mPermissions.add(mPermissions[index]);
      }
      if (!mTypes.contains(HealthDataType.HEIGHT)) {
        mTypes.add(HealthDataType.HEIGHT);
        mPermissions.add(mPermissions[index]);
      }
      mTypes.remove(HealthDataType.BODY_MASS_INDEX);
      mPermissions.removeAt(index);
    }
  }

  /// Calculate the BMI using the last observed height and weight values.
  Future<List<HealthDataPoint>> _computeAndroidBMI(
      DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> heights =
        await _prepareQuery(startTime, endTime, HealthDataType.HEIGHT);

    if (heights.isEmpty) {
      return [];
    }

    List<HealthDataPoint> weights =
        await _prepareQuery(startTime, endTime, HealthDataType.WEIGHT);

    double h =
        (heights.last.value as NumericHealthValue).numericValue.toDouble();

    const dataType = HealthDataType.BODY_MASS_INDEX;
    final unit = _dataTypeToUnit[dataType]!;

    final bmiHealthPoints = <HealthDataPoint>[];
    for (var i = 0; i < weights.length; i++) {
      final bmiValue =
          (weights[i].value as NumericHealthValue).numericValue.toDouble() /
              (h * h);
      final x = HealthDataPoint(
          NumericHealthValue(bmiValue),
          dataType,
          unit,
          weights[i].dateFrom,
          weights[i].dateTo,
          _platformType,
          _deviceId!,
          '',
          '');

      bmiHealthPoints.add(x);
    }
    return bmiHealthPoints;
  }

  /// Saves health data into Apple Health or Google Fit.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [value] - the health data's value in double
  /// * [type] - the value's HealthDataType
  /// * [startTime] - the start time when this [value] is measured.
  ///   + It must be equal to or earlier than [endTime].
  /// * [endTime] - the end time when this [value] is measured.
  ///   + It must be equal to or later than [startTime].
  ///   + Simply set [endTime] equal to [startTime] if the [value] is measured only at a specific point in time.
  ///
  /// Values for Sleep and Headache are ignored and will be automatically assigned the coresponding value.
  Future<bool> writeHealthData(
    double value,
    HealthDataType type,
    DateTime startTime,
    DateTime endTime, {
    HealthDataUnit? unit,
  }) async {
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");
    if ([
      HealthDataType.HIGH_HEART_RATE_EVENT,
      HealthDataType.LOW_HEART_RATE_EVENT,
      HealthDataType.IRREGULAR_HEART_RATE_EVENT
    ].contains(type))
      throw ArgumentError(
          "$type - iOS doesnt support writing this data type in HealthKit");

    // Assign default unit if not specified
    unit ??= _dataTypeToUnit[type]!;

    // Align values to type in cases where the type defines the value.
    // E.g. SLEEP_IN_BED should have value 0
    if (type == HealthDataType.SLEEP_ASLEEP ||
        type == HealthDataType.SLEEP_AWAKE ||
        type == HealthDataType.SLEEP_IN_BED ||
        type == HealthDataType.HEADACHE_NOT_PRESENT ||
        type == HealthDataType.HEADACHE_MILD ||
        type == HealthDataType.HEADACHE_MODERATE ||
        type == HealthDataType.HEADACHE_SEVERE ||
        type == HealthDataType.HEADACHE_UNSPECIFIED) {
      value = _alignValue(type).toDouble();
    }

    Map<String, dynamic> args = {
      'value': value,
      'dataTypeKey': type.typeToString(),
      'dataUnitKey': type.typeToString(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch
    };
    bool? success = await _channel.invokeMethod('writeData', args);
    return success ?? false;
  }

  /// Saves audiogram into Apple Health.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [frequencies] - array of frequencies of the test
  /// * [leftEarSensitivities] threshold in decibel for the left ear
  /// * [rightEarSensitivities] threshold in decibel for the left ear
  /// * [startTime] - the start time when the audiogram is measured.
  ///   + It must be equal to or earlier than [endTime].
  /// * [endTime] - the end time when the audiogram is measured.
  ///   + It must be equal to or later than [startTime].
  ///   + Simply set [endTime] equal to [startTime] if the audiogram is measured only at a specific point in time.
  /// * [metadata] - optional map of keys, both HKMetadataKeyExternalUUID and HKMetadataKeyDeviceName are required
  Future<bool> writeAudiogram(
      List<double> frequencies,
      List<double> leftEarSensitivities,
      List<double> rightEarSensitivities,
      DateTime startTime,
      DateTime endTime,
      {Map<String, dynamic>? metadata}) async {
    if (frequencies.isEmpty ||
        leftEarSensitivities.isEmpty ||
        rightEarSensitivities.isEmpty)
      throw ArgumentError(
          "frequencies, leftEarSensitivities and rightEarSensitivities can't be empty");
    if (frequencies.length != leftEarSensitivities.length ||
        rightEarSensitivities.length != leftEarSensitivities.length)
      throw ArgumentError(
          "frequencies, leftEarSensitivities and rightEarSensitivities need to be of the same length");
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");
    if (_platformType == PlatformType.ANDROID)
      throw UnsupportedError("writeAudiogram is not supported on Android");
    Map<String, dynamic> args = {
      'frequencies': frequencies,
      'leftEarSensitivities': leftEarSensitivities,
      'rightEarSensitivities': rightEarSensitivities,
      'dataTypeKey': HealthDataType.AUDIOGRAM.typeToString(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'metadata': metadata,
    };
    bool? success = await _channel.invokeMethod('writeAudiogram', args);
    return success ?? false;
  }

  /// Fetch a list of health data points based on [types].
  Future<List<HealthDataPoint>> getHealthDataFromTypes(
    DateTime startTime,
    DateTime endTime,
    List<HealthDataType> types,
  ) async {
    List<HealthDataPoint> dataPoints = [];

    for (var type in types) {
      final result = await _prepareQuery(startTime, endTime, type);
      dataPoints.addAll(result);
    }

    const int threshold = 100;
    if (dataPoints.length > threshold) {
      return compute(removeDuplicates, dataPoints);
    }

    return removeDuplicates(dataPoints);
  }

  /// Prepares a query, i.e. checks if the types are available, etc.
  Future<List<HealthDataPoint>> _prepareQuery(
      DateTime startTime, DateTime endTime, HealthDataType dataType) async {
    // Ask for device ID only once
    _deviceId ??= _platformType == PlatformType.ANDROID
        ? (await _deviceInfo.androidInfo).androidId
        : (await _deviceInfo.iosInfo).identifierForVendor;

    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw HealthException(
          dataType, 'Not available on platform $_platformType');
    }

    // If BodyMassIndex is requested on Android, calculate this manually
    if (dataType == HealthDataType.BODY_MASS_INDEX &&
        _platformType == PlatformType.ANDROID) {
      return _computeAndroidBMI(startTime, endTime);
    }
    return await _dataQuery(startTime, endTime, dataType);
  }

  /// The main function for fetching health data
  Future<List<HealthDataPoint>> _dataQuery(
      DateTime startTime, DateTime endTime, HealthDataType dataType) async {
    final args = <String, dynamic>{
      'dataTypeKey': dataType.typeToString(),
      'dataUnitKey': _dataTypeToUnit[dataType]!.typeToString(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch
    };
    final fetchedDataPoints = await _channel.invokeMethod('getData', args);
    if (fetchedDataPoints != null) {
      final mesg = <String, dynamic>{
        "dataType": dataType,
        "dataPoints": fetchedDataPoints,
        "deviceId": _deviceId!,
      };
      const thresHold = 100;
      // If the no. of data points are larger than the threshold,
      // call the compute method to spawn an Isolate to do the parsing in a separate thread.
      if (fetchedDataPoints.length > thresHold) {
        return compute(_parse, mesg);
      }
      return _parse(mesg);
    } else {
      return <HealthDataPoint>[];
    }
  }

  static List<HealthDataPoint> _parse(Map<String, dynamic> message) {
    final dataType = message["dataType"];
    final dataPoints = message["dataPoints"];
    final device = message["deviceId"];
    final unit = _dataTypeToUnit[dataType]!;
    final list = dataPoints.map<HealthDataPoint>((e) {
      // Handling different [HealthValue] types
      HealthValue value;
      if (dataType == HealthDataType.AUDIOGRAM) {
        value = AudiogramHealthValue.fromJson(e);
      } else if (dataType == HealthDataType.WORKOUT) {
        value = WorkoutHealthValue.fromJson(e);
      } else {
        value = NumericHealthValue(e['value']);
      }
      final DateTime from = DateTime.fromMillisecondsSinceEpoch(e['date_from']);
      final DateTime to = DateTime.fromMillisecondsSinceEpoch(e['date_to']);
      final String sourceId = e["source_id"];
      final String sourceName = e["source_name"];
      return HealthDataPoint(
        value,
        dataType,
        unit,
        from,
        to,
        _platformType,
        device,
        sourceId,
        sourceName,
      );
    }).toList();

    return list;
  }

  /// Given an array of [HealthDataPoint]s, this method will return the array
  /// without any duplicates.
  static List<HealthDataPoint> removeDuplicates(List<HealthDataPoint> points) {
    return LinkedHashSet.of(points).toList();
  }

  /// Get the total numbner of steps within a specific time period.
  /// Returns null if not successful.
  ///
  /// Is a fix according to https://stackoverflow.com/questions/29414386/step-count-retrieved-through-google-fit-api-does-not-match-step-count-displayed/29415091#29415091
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final args = <String, dynamic>{
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch
    };
    final stepsCount = await _channel.invokeMethod<int?>(
      'getTotalStepsInInterval',
      args,
    );
    return stepsCount;
  }

  int _alignValue(HealthDataType type) {
    switch (type) {
      case HealthDataType.SLEEP_IN_BED:
        return 0;
      case HealthDataType.SLEEP_ASLEEP:
        return 1;
      case HealthDataType.SLEEP_AWAKE:
        return 2;
      case HealthDataType.HEADACHE_UNSPECIFIED:
        return 0;
      case HealthDataType.HEADACHE_NOT_PRESENT:
        return 1;
      case HealthDataType.HEADACHE_MILD:
        return 2;
      case HealthDataType.HEADACHE_MODERATE:
        return 3;
      case HealthDataType.HEADACHE_SEVERE:
        return 4;
      default:
        throw HealthException(type,
            "HealthDataType was not aligned correctly - please report bug at https://github.com/cph-cachet/flutter-plugins/issues");
    }
  }

  /// Write workout data to Apple Health
  ///
  /// Returns true if successfully added workout data.
  ///
  /// Parameters:
  /// - [activityType] The type of activity performed
  /// - [start] The start time of the workout
  /// - [end] The end time of the workout
  /// - [totalEnergyBurned] The total energy burned during the workout
  /// - [totalEnergyBurnedUnit] The UNIT used to measure [totalEnergyBurned] *ONLY FOR IOS*
  /// - [totalDistance] The total distance traveled during the workout
  /// - [totalDistanceUnit]  The UNIT used to measure [totalDistance] *ONLY FOR IOS*
  Future<bool> writeWorkoutData(
    HealthWorkoutActivityType activityType,
    DateTime start,
    DateTime end, {
    int? totalEnergyBurned,
    HealthDataUnit? totalEnergyBurnedUnit,
    int? totalDistance,
    HealthDataUnit? totalDistanceUnit,
  }) async {
    final args = <String, dynamic>{
      'activityType': activityType.typeToString(),
      'startTime': start.millisecondsSinceEpoch,
      'endTime': end.millisecondsSinceEpoch,
      'totalEnergyBurned': totalEnergyBurned,
      'totalEnergyBurnedUnit': _enumToString(totalEnergyBurnedUnit),
      'totalDistance': totalDistance,
      'totalDistanceUnit': _enumToString(totalDistanceUnit),
    };
    final success = await _channel.invokeMethod('writeWorkoutData', args);
    return success ?? false;
  }
}
