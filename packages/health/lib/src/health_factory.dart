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
  late bool _useHealthConnectIfAvailable;

  static PlatformType _platformType =
      Platform.isAndroid ? PlatformType.ANDROID : PlatformType.IOS;

  /// The plugin was created to use Health Connect (if true) or Google Fit (if false).
  bool get useHealthConnectIfAvailable => _useHealthConnectIfAvailable;

  HealthFactory({bool useHealthConnectIfAvailable = false}) {
    _useHealthConnectIfAvailable = useHealthConnectIfAvailable;
    if (_useHealthConnectIfAvailable)
      _channel.invokeMethod('useHealthConnectIfAvailable');
  }

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
  Future<bool?> hasPermissions(List<HealthDataType> types,
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
      "types": mTypes.map((type) => type.name).toList(),
      "permissions": mPermissions,
    });
  }

  /// Revokes permissions of all types.
  /// Uses `disableFit()` on Google Fit.
  ///
  /// Not implemented on iOS as there is no way to programmatically remove access.
  Future<void> revokePermissions() async {
    try {
      if (_platformType == PlatformType.IOS) {
        throw UnsupportedError(
            'Revoke permissions is not supported on iOS. Please revoke permissions manually in the settings.');
      }
      await _channel.invokeMethod('revokePermissions');
      return;
    } catch (e) {
      print(e);
    }
  }

  /// Disconnect Google fit.
  ///
  /// Not supported on iOS and method does nothing.
  Future<bool?> disconnect(
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

    List<String> keys = mTypes.map((dataType) => dataType.name).toList();

    return await _channel.invokeMethod(
        'disconnect', {'types': keys, "permissions": mPermissions});
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
  ///  Caveats:
  ///
  ///  * This method may block if permissions are already granted. Hence, check
  ///    [hasPermissions] before calling this method.
  ///  * As Apple HealthKit will not disclose if READ access has been granted for
  ///    a data type due to privacy concern, this method will return **true if
  ///    the window asking for permission was showed to the user without errors**
  ///    if it is called on iOS with a READ or READ_WRITE access.
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    if (permissions != null && permissions.length != types.length) {
      throw ArgumentError(
          'The length of [types] must be same as that of [permissions].');
    }

    if (permissions != null) {
      for (int i = 0; i < types.length; i++) {
        final type = types[i];
        final permission = permissions[i];
        if ((type == HealthDataType.ELECTROCARDIOGRAM ||
                type == HealthDataType.HIGH_HEART_RATE_EVENT ||
                type == HealthDataType.LOW_HEART_RATE_EVENT ||
                type == HealthDataType.IRREGULAR_HEART_RATE_EVENT ||
                type == HealthDataType.WALKING_HEART_RATE) &&
            permission != HealthDataAccess.READ) {
          throw ArgumentError(
              'Requesting WRITE permission on ELECTROCARDIOGRAM / HIGH_HEART_RATE_EVENT / LOW_HEART_RATE_EVENT / IRREGULAR_HEART_RATE_EVENT / WALKING_HEART_RATE is not allowed.');
        }
      }
    }

    final mTypes = List<HealthDataType>.from(types, growable: true);
    final mPermissions = permissions == null
        ? List<int>.filled(types.length, HealthDataAccess.READ.index,
            growable: true)
        : permissions.map((permission) => permission.index).toList();

    // on Android, if BMI is requested, then also ask for weight and height
    if (_platformType == PlatformType.ANDROID) _handleBMI(mTypes, mPermissions);

    List<String> keys = mTypes.map((e) => e.name).toList();
    print(
        '>> trying to get permissions for $keys with permissions $mPermissions');
    final bool? isAuthorized = await _channel.invokeMethod(
        'requestAuthorization', {'types': keys, "permissions": mPermissions});
    print('>> isAuthorized: $isAuthorized');
    return isAuthorized ?? false;
  }

  /// Obtains health and weight if BMI is requested on Android.
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
      DateTime startTime, DateTime endTime, bool includeManualEntry) async {
    List<HealthDataPoint> heights = await _prepareQuery(
        startTime, endTime, HealthDataType.HEIGHT, includeManualEntry);

    if (heights.isEmpty) {
      return [];
    }

    List<HealthDataPoint> weights = await _prepareQuery(
        startTime, endTime, HealthDataType.WEIGHT, includeManualEntry);

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
        '',
        !includeManualEntry,
        null,
      );

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
  /// * [unit] - <mark>(iOS ONLY)</mark> the unit the health data is measured in.
  ///
  /// Values for Sleep and Headache are ignored and will be automatically assigned the coresponding value.
  Future<bool> writeHealthData(
    double value,
    HealthDataType type,
    DateTime startTime,
    DateTime endTime, {
    HealthDataUnit? unit,
  }) async {
    if (type == HealthDataType.WORKOUT)
      throw ArgumentError(
          "Adding workouts should be done using the writeWorkoutData method.");
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");
    if ({
          HealthDataType.HIGH_HEART_RATE_EVENT,
          HealthDataType.LOW_HEART_RATE_EVENT,
          HealthDataType.IRREGULAR_HEART_RATE_EVENT,
          HealthDataType.ELECTROCARDIOGRAM,
        }.contains(type) &&
        _platformType == PlatformType.IOS)
      throw ArgumentError(
          "$type - iOS doesnt support writing this data type in HealthKit");

    // Assign default unit if not specified
    unit ??= _dataTypeToUnit[type]!;

    // Align values to type in cases where the type defines the value.
    // E.g. SLEEP_IN_BED should have value 0
    if (type == HealthDataType.SLEEP_ASLEEP ||
        type == HealthDataType.SLEEP_AWAKE ||
        type == HealthDataType.SLEEP_IN_BED ||
        type == HealthDataType.SLEEP_DEEP ||
        type == HealthDataType.SLEEP_REM ||
        type == HealthDataType.SLEEP_ASLEEP_CORE ||
        type == HealthDataType.SLEEP_ASLEEP_DEEP ||
        type == HealthDataType.SLEEP_ASLEEP_REM ||
        type == HealthDataType.HEADACHE_NOT_PRESENT ||
        type == HealthDataType.HEADACHE_MILD ||
        type == HealthDataType.HEADACHE_MODERATE ||
        type == HealthDataType.HEADACHE_SEVERE ||
        type == HealthDataType.HEADACHE_UNSPECIFIED) {
      value = _alignValue(type).toDouble();
    }

    Map<String, dynamic> args = {
      'value': value,
      'dataTypeKey': type.name,
      'dataUnitKey': unit.name,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch
    };
    bool? success = await _channel.invokeMethod('writeData', args);
    return success ?? false;
  }

  /// Deletes all records of the given type for a given period of time
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [type] - the value's HealthDataType
  /// * [startTime] - the start time when this [value] is measured.
  ///   + It must be equal to or earlier than [endTime].
  /// * [endTime] - the end time when this [value] is measured.
  ///   + It must be equal to or later than [startTime].
  Future<bool> delete(
      HealthDataType type, DateTime startTime, DateTime endTime) async {
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");

    Map<String, dynamic> args = {
      'dataTypeKey': type.name,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch
    };
    bool? success = await _channel.invokeMethod('delete', args);
    return success ?? false;
  }

  /// Saves blood pressure record into Apple Health or Google Fit.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [systolic] - the systolic part of the blood pressure
  /// * [diastolic] - the diastolic part of the blood pressure
  /// * [startTime] - the start time when this [value] is measured.
  ///   + It must be equal to or earlier than [endTime].
  /// * [endTime] - the end time when this [value] is measured.
  ///   + It must be equal to or later than [startTime].
  ///   + Simply set [endTime] equal to [startTime] if the blood pressure is measured only at a specific point in time.
  Future<bool> writeBloodPressure(
      int systolic, int diastolic, DateTime startTime, DateTime endTime) async {
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");

    Map<String, dynamic> args = {
      'systolic': systolic,
      'diastolic': diastolic,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch
    };
    bool? success = await _channel.invokeMethod('writeBloodPressure', args);
    return success ?? false;
  }

  /// Saves blood oxygen saturation record into Apple Health or Google Fit/Health Connect.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [saturation] - the saturation of the blood oxygen in percentage
  /// * [flowRate] - optional supplemental oxygen flow rate, only supported on Google Fit (default 0.0)
  /// * [startTime] - the start time when this [value] is measured.
  ///   + It must be equal to or earlier than [endTime].
  /// * [endTime] - the end time when this [value] is measured.
  ///   + It must be equal to or later than [startTime].
  ///   + Simply set [endTime] equal to [startTime] if the blood oxygen saturation is measured only at a specific point in time.
  Future<bool> writeBloodOxygen(
      double saturation, DateTime startTime, DateTime endTime,
      {double flowRate = 0.0}) async {
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");
    bool? success;

    if (_platformType == PlatformType.IOS) {
      success = await writeHealthData(
          saturation, HealthDataType.BLOOD_OXYGEN, startTime, endTime);
    } else if (_platformType == PlatformType.ANDROID) {
      Map<String, dynamic> args = {
        'value': saturation,
        'flowRate': flowRate,
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
        'dataTypeKey': HealthDataType.BLOOD_OXYGEN.name,
      };
      success = await _channel.invokeMethod('writeBloodOxygen', args);
    }
    return success ?? false;
  }

  /// Saves meal record into Apple Health or Google Fit.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [startTime] - the start time when the meal was consumed.
  ///   + It must be equal to or earlier than [endTime].
  /// * [endTime] - the end time when the meal was consumed.
  ///   + It must be equal to or later than [startTime].
  /// * [caloriesConsumed] - total calories consumed with this meal.
  /// * [carbohydrates] - optional carbohydrates information.
  /// * [protein] - optional protein information.
  /// * [fatTotal] - optional total fat information.
  /// * [name] - optional name information about this meal.
  Future<bool> writeMeal(
      DateTime startTime,
      DateTime endTime,
      double? caloriesConsumed,
      double? carbohydrates,
      double? protein,
      double? fatTotal,
      String? name,
      double? caffeine,
      MealType mealType) async {
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");

    Map<String, dynamic> args = {
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'caloriesConsumed': caloriesConsumed,
      'carbohydrates': carbohydrates,
      'protein': protein,
      'fatTotal': fatTotal,
      'name': name,
      'caffeine': caffeine,
      'mealType': mealType.name,
    };
    bool? success = await _channel.invokeMethod('writeMeal', args);
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
      'dataTypeKey': HealthDataType.AUDIOGRAM.name,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'metadata': metadata,
    };
    bool? success = await _channel.invokeMethod('writeAudiogram', args);
    return success ?? false;
  }

  /// Fetch a list of health data points based on [types].
  Future<List<HealthDataPoint>> getHealthDataFromTypes(
      DateTime startTime, DateTime endTime, List<HealthDataType> types,
      {bool includeManualEntry = true}) async {
    List<HealthDataPoint> dataPoints = [];

    for (var type in types) {
      final result =
          await _prepareQuery(startTime, endTime, type, includeManualEntry);
      dataPoints.addAll(result);
    }

    const int threshold = 100;
    if (dataPoints.length > threshold) {
      return compute(removeDuplicates, dataPoints);
    }

    return removeDuplicates(dataPoints);
  }

  /// Fetch a list of health data points based on [types].
  Future<List<HealthDataPoint>> getHealthIntervalDataFromTypes(
      DateTime startDate,
      DateTime endDate,
      List<HealthDataType> types,
      int interval,
      {bool includeManualEntry = true}) async {
    List<HealthDataPoint> dataPoints = [];

    for (var type in types) {
      final result = await _prepareIntervalQuery(
          startDate, endDate, type, interval, includeManualEntry);
      dataPoints.addAll(result);
    }

    return removeDuplicates(dataPoints);
  }

  /// Fetch a list of health data points based on [types].
  Future<List<HealthDataPoint>> getHealthAggregateDataFromTypes(
      DateTime startDate, DateTime endDate, List<HealthDataType> types,
      {int activitySegmentDuration = 1, bool includeManualEntry = true}) async {
    List<HealthDataPoint> dataPoints = [];

    final result = await _prepareAggregateQuery(
        startDate, endDate, types, activitySegmentDuration, includeManualEntry);
    dataPoints.addAll(result);

    return removeDuplicates(dataPoints);
  }

  /// Prepares an interval query, i.e. checks if the types are available, etc.
  Future<List<HealthDataPoint>> _prepareQuery(
      DateTime startTime,
      DateTime endTime,
      HealthDataType dataType,
      bool includeManualEntry) async {
    // Ask for device ID only once
    _deviceId ??= _platformType == PlatformType.ANDROID
        ? (await _deviceInfo.androidInfo).id
        : (await _deviceInfo.iosInfo).identifierForVendor;

    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw HealthException(
          dataType, 'Not available on platform $_platformType');
    }

    // If BodyMassIndex is requested on Android, calculate this manually
    if (dataType == HealthDataType.BODY_MASS_INDEX &&
        _platformType == PlatformType.ANDROID) {
      return _computeAndroidBMI(startTime, endTime, includeManualEntry);
    }
    return await _dataQuery(startTime, endTime, dataType, includeManualEntry);
  }

  /// Prepares an interval query, i.e. checks if the types are available, etc.
  Future<List<HealthDataPoint>> _prepareIntervalQuery(
      DateTime startDate,
      DateTime endDate,
      HealthDataType dataType,
      int interval,
      bool includeManualEntry) async {
    // Ask for device ID only once
    _deviceId ??= _platformType == PlatformType.ANDROID
        ? (await _deviceInfo.androidInfo).id
        : (await _deviceInfo.iosInfo).identifierForVendor;

    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw HealthException(
          dataType, 'Not available on platform $_platformType');
    }

    return await _dataIntervalQuery(
        startDate, endDate, dataType, interval, includeManualEntry);
  }

  /// Prepares an aggregate query, i.e. checks if the types are available, etc.
  Future<List<HealthDataPoint>> _prepareAggregateQuery(
      DateTime startDate,
      DateTime endDate,
      List<HealthDataType> dataTypes,
      int activitySegmentDuration,
      bool includeManualEntry) async {
    // Ask for device ID only once
    _deviceId ??= _platformType == PlatformType.ANDROID
        ? (await _deviceInfo.androidInfo).id
        : (await _deviceInfo.iosInfo).identifierForVendor;

    for (var type in dataTypes) {
      // If not implemented on platform, throw an exception
      if (!isDataTypeAvailable(type)) {
        throw HealthException(type, 'Not available on platform $_platformType');
      }
    }

    return await _dataAggregateQuery(startDate, endDate, dataTypes,
        activitySegmentDuration, includeManualEntry);
  }

  /// Fetches data points from Android/iOS native code.
  Future<List<HealthDataPoint>> _dataQuery(DateTime startTime, DateTime endTime,
      HealthDataType dataType, bool includeManualEntry) async {
    final args = <String, dynamic>{
      'dataTypeKey': dataType.name,
      'dataUnitKey': _dataTypeToUnit[dataType]!.name,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'includeManualEntry': includeManualEntry
    };
    final fetchedDataPoints = await _channel.invokeMethod('getData', args);

    if (fetchedDataPoints != null) {
      final mesg = <String, dynamic>{
        "dataType": dataType,
        "dataPoints": fetchedDataPoints,
        "deviceId": '$_deviceId',
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

  /// function for fetching statistic health data
  Future<List<HealthDataPoint>> _dataIntervalQuery(
      DateTime startDate,
      DateTime endDate,
      HealthDataType dataType,
      int interval,
      bool includeManualEntry) async {
    final args = <String, dynamic>{
      'dataTypeKey': dataType.name,
      'dataUnitKey': _dataTypeToUnit[dataType]!.name,
      'startTime': startDate.millisecondsSinceEpoch,
      'endTime': endDate.millisecondsSinceEpoch,
      'interval': interval,
      'includeManualEntry': includeManualEntry
    };

    final fetchedDataPoints =
        await _channel.invokeMethod('getIntervalData', args);
    if (fetchedDataPoints != null) {
      final mesg = <String, dynamic>{
        "dataType": dataType,
        "dataPoints": fetchedDataPoints,
        "deviceId": _deviceId!,
      };
      return _parse(mesg);
    }
    return <HealthDataPoint>[];
  }

  /// function for fetching statistic health data
  Future<List<HealthDataPoint>> _dataAggregateQuery(
      DateTime startDate,
      DateTime endDate,
      List<HealthDataType> dataTypes,
      int activitySegmentDuration,
      bool includeManualEntry) async {
    final args = <String, dynamic>{
      'dataTypeKeys': dataTypes.map((dataType) => dataType.name).toList(),
      'startTime': startDate.millisecondsSinceEpoch,
      'endTime': endDate.millisecondsSinceEpoch,
      'activitySegmentDuration': activitySegmentDuration,
      'includeManualEntry': includeManualEntry
    };

    final fetchedDataPoints =
        await _channel.invokeMethod('getAggregateData', args);
    if (fetchedDataPoints != null) {
      final mesg = <String, dynamic>{
        "dataType": HealthDataType.WORKOUT,
        "dataPoints": fetchedDataPoints,
        "deviceId": _deviceId!,
      };
      return _parse(mesg);
    }
    return <HealthDataPoint>[];
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
      } else if (dataType == HealthDataType.WORKOUT &&
          e["totalEnergyBurned"] != null) {
        value = WorkoutHealthValue.fromJson(e);
      } else if (dataType == HealthDataType.ELECTROCARDIOGRAM) {
        value = ElectrocardiogramHealthValue.fromJson(e);
      } else if (dataType == HealthDataType.NUTRITION) {
        value = NutritionHealthValue.fromJson(e);
      } else {
        value = NumericHealthValue(e['value'] ?? 0);
      }
      final DateTime from = DateTime.fromMillisecondsSinceEpoch(e['date_from']);
      final DateTime to = DateTime.fromMillisecondsSinceEpoch(e['date_to']);
      final String sourceId = e["source_id"];
      final String sourceName = e["source_name"];
      final bool? isManualEntry = e["is_manual_entry"];

      // Set WorkoutSummary
      WorkoutSummary? workoutSummary;
      if (e["workout_type"] != null ||
          e["total_distance"] != null ||
          e["total_energy_burned"] != null ||
          e["total_steps"] != null) {
        workoutSummary = WorkoutSummary(
          e["workout_type"] ?? '',
          e["total_distance"] ?? 0,
          e["total_energy_burned"] ?? 0,
          e["total_steps"] ?? 0,
        );
      }
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
        isManualEntry,
        workoutSummary,
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

  /// Assigns numbers to specific [HealthDataType]s.
  int _alignValue(HealthDataType type) {
    switch (type) {
      case HealthDataType.SLEEP_IN_BED:
        return 0;
      case HealthDataType.SLEEP_AWAKE:
        return 2;
      case HealthDataType.SLEEP_ASLEEP:
        return 3;
      case HealthDataType.SLEEP_DEEP:
        return 4;
      case HealthDataType.SLEEP_REM:
        return 5;
      case HealthDataType.SLEEP_ASLEEP_CORE:
        return 3;
      case HealthDataType.SLEEP_ASLEEP_DEEP:
        return 4;
      case HealthDataType.SLEEP_ASLEEP_REM:
        return 5;
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
  /// - [totalEnergyBurnedUnit] The UNIT used to measure [totalEnergyBurned] *ONLY FOR IOS* Default value is KILOCALORIE.
  /// - [totalDistance] The total distance traveled during the workout
  /// - [totalDistanceUnit] The UNIT used to measure [totalDistance] *ONLY FOR IOS* Default value is METER.
  Future<bool> writeWorkoutData(
    HealthWorkoutActivityType activityType,
    DateTime start,
    DateTime end, {
    int? totalEnergyBurned,
    HealthDataUnit totalEnergyBurnedUnit = HealthDataUnit.KILOCALORIE,
    int? totalDistance,
    HealthDataUnit totalDistanceUnit = HealthDataUnit.METER,
  }) async {
    // Check that value is on the current Platform
    if (_platformType == PlatformType.IOS && !_isOnIOS(activityType)) {
      throw HealthException(activityType,
          "Workout activity type $activityType is not supported on iOS");
    } else if (_platformType == PlatformType.ANDROID &&
        !_isOnAndroid(activityType)) {
      throw HealthException(activityType,
          "Workout activity type $activityType is not supported on Android");
    }
    final args = <String, dynamic>{
      'activityType': activityType.name,
      'startTime': start.millisecondsSinceEpoch,
      'endTime': end.millisecondsSinceEpoch,
      'totalEnergyBurned': totalEnergyBurned,
      'totalEnergyBurnedUnit': totalEnergyBurnedUnit.name,
      'totalDistance': totalDistance,
      'totalDistanceUnit': totalDistanceUnit.name,
    };
    final success = await _channel.invokeMethod('writeWorkoutData', args);
    return success ?? false;
  }

  /// Check if the given [HealthWorkoutActivityType] is supported on the iOS platform
  bool _isOnIOS(HealthWorkoutActivityType type) {
    // Returns true if the type is part of the iOS set
    return {
      HealthWorkoutActivityType.ARCHERY,
      HealthWorkoutActivityType.BADMINTON,
      HealthWorkoutActivityType.BASEBALL,
      HealthWorkoutActivityType.BASKETBALL,
      HealthWorkoutActivityType.BIKING,
      HealthWorkoutActivityType.BOXING,
      HealthWorkoutActivityType.CRICKET,
      HealthWorkoutActivityType.CURLING,
      HealthWorkoutActivityType.ELLIPTICAL,
      HealthWorkoutActivityType.FENCING,
      HealthWorkoutActivityType.AMERICAN_FOOTBALL,
      HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL,
      HealthWorkoutActivityType.SOCCER,
      HealthWorkoutActivityType.GOLF,
      HealthWorkoutActivityType.GYMNASTICS,
      HealthWorkoutActivityType.HANDBALL,
      HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING,
      HealthWorkoutActivityType.HIKING,
      HealthWorkoutActivityType.HOCKEY,
      HealthWorkoutActivityType.SKATING,
      HealthWorkoutActivityType.JUMP_ROPE,
      HealthWorkoutActivityType.KICKBOXING,
      HealthWorkoutActivityType.MARTIAL_ARTS,
      HealthWorkoutActivityType.PILATES,
      HealthWorkoutActivityType.RACQUETBALL,
      HealthWorkoutActivityType.ROWING,
      HealthWorkoutActivityType.RUGBY,
      HealthWorkoutActivityType.RUNNING,
      HealthWorkoutActivityType.SAILING,
      HealthWorkoutActivityType.CROSS_COUNTRY_SKIING,
      HealthWorkoutActivityType.DOWNHILL_SKIING,
      HealthWorkoutActivityType.SNOWBOARDING,
      HealthWorkoutActivityType.SOFTBALL,
      HealthWorkoutActivityType.SQUASH,
      HealthWorkoutActivityType.STAIR_CLIMBING,
      HealthWorkoutActivityType.SWIMMING,
      HealthWorkoutActivityType.TABLE_TENNIS,
      HealthWorkoutActivityType.TENNIS,
      HealthWorkoutActivityType.VOLLEYBALL,
      HealthWorkoutActivityType.WALKING,
      HealthWorkoutActivityType.WATER_POLO,
      HealthWorkoutActivityType.YOGA,
      HealthWorkoutActivityType.BOWLING,
      HealthWorkoutActivityType.CROSS_TRAINING,
      HealthWorkoutActivityType.TRACK_AND_FIELD,
      HealthWorkoutActivityType.DISC_SPORTS,
      HealthWorkoutActivityType.LACROSSE,
      HealthWorkoutActivityType.PREPARATION_AND_RECOVERY,
      HealthWorkoutActivityType.FLEXIBILITY,
      HealthWorkoutActivityType.COOLDOWN,
      HealthWorkoutActivityType.WHEELCHAIR_WALK_PACE,
      HealthWorkoutActivityType.WHEELCHAIR_RUN_PACE,
      HealthWorkoutActivityType.HAND_CYCLING,
      HealthWorkoutActivityType.CORE_TRAINING,
      HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING,
      HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
      HealthWorkoutActivityType.MIXED_CARDIO,
      HealthWorkoutActivityType.STAIRS,
      HealthWorkoutActivityType.STEP_TRAINING,
      HealthWorkoutActivityType.FITNESS_GAMING,
      HealthWorkoutActivityType.BARRE,
      HealthWorkoutActivityType.CARDIO_DANCE,
      HealthWorkoutActivityType.SOCIAL_DANCE,
      HealthWorkoutActivityType.MIND_AND_BODY,
      HealthWorkoutActivityType.PICKLEBALL,
      HealthWorkoutActivityType.CLIMBING,
      HealthWorkoutActivityType.EQUESTRIAN_SPORTS,
      HealthWorkoutActivityType.FISHING,
      HealthWorkoutActivityType.HUNTING,
      HealthWorkoutActivityType.PLAY,
      HealthWorkoutActivityType.SNOW_SPORTS,
      HealthWorkoutActivityType.PADDLE_SPORTS,
      HealthWorkoutActivityType.SURFING_SPORTS,
      HealthWorkoutActivityType.WATER_FITNESS,
      HealthWorkoutActivityType.WATER_SPORTS,
      HealthWorkoutActivityType.TAI_CHI,
      HealthWorkoutActivityType.WRESTLING,
      HealthWorkoutActivityType.OTHER,
    }.contains(type);
  }

  /// Check if the given [HealthWorkoutActivityType] is supported on the Android platform
  bool _isOnAndroid(HealthWorkoutActivityType type) {
    // Returns true if the type is part of the Android set
    return {
      // Both
      HealthWorkoutActivityType.ARCHERY,
      HealthWorkoutActivityType.BADMINTON,
      HealthWorkoutActivityType.BASEBALL,
      HealthWorkoutActivityType.BASKETBALL,
      HealthWorkoutActivityType.BIKING,
      HealthWorkoutActivityType.BOXING,
      HealthWorkoutActivityType.CRICKET,
      HealthWorkoutActivityType.CURLING,
      HealthWorkoutActivityType.ELLIPTICAL,
      HealthWorkoutActivityType.FENCING,
      HealthWorkoutActivityType.AMERICAN_FOOTBALL,
      HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL,
      HealthWorkoutActivityType.SOCCER,
      HealthWorkoutActivityType.GOLF,
      HealthWorkoutActivityType.GYMNASTICS,
      HealthWorkoutActivityType.HANDBALL,
      HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING,
      HealthWorkoutActivityType.HIKING,
      HealthWorkoutActivityType.HOCKEY,
      HealthWorkoutActivityType.SKATING,
      HealthWorkoutActivityType.JUMP_ROPE,
      HealthWorkoutActivityType.KICKBOXING,
      HealthWorkoutActivityType.MARTIAL_ARTS,
      HealthWorkoutActivityType.PILATES,
      HealthWorkoutActivityType.RACQUETBALL,
      HealthWorkoutActivityType.ROWING,
      HealthWorkoutActivityType.RUGBY,
      HealthWorkoutActivityType.RUNNING,
      HealthWorkoutActivityType.SAILING,
      HealthWorkoutActivityType.CROSS_COUNTRY_SKIING,
      HealthWorkoutActivityType.DOWNHILL_SKIING,
      HealthWorkoutActivityType.SNOWBOARDING,
      HealthWorkoutActivityType.SOFTBALL,
      HealthWorkoutActivityType.SQUASH,
      HealthWorkoutActivityType.STAIR_CLIMBING,
      HealthWorkoutActivityType.SWIMMING,
      HealthWorkoutActivityType.TABLE_TENNIS,
      HealthWorkoutActivityType.TENNIS,
      HealthWorkoutActivityType.VOLLEYBALL,
      HealthWorkoutActivityType.WALKING,
      HealthWorkoutActivityType.WATER_POLO,
      HealthWorkoutActivityType.YOGA,

      // Android only
      // Once Google Fit is removed, this list needs to be changed
      HealthWorkoutActivityType.AEROBICS,
      HealthWorkoutActivityType.BIATHLON,
      HealthWorkoutActivityType.BIKING_HAND,
      HealthWorkoutActivityType.BIKING_MOUNTAIN,
      HealthWorkoutActivityType.BIKING_ROAD,
      HealthWorkoutActivityType.BIKING_SPINNING,
      HealthWorkoutActivityType.BIKING_STATIONARY,
      HealthWorkoutActivityType.BIKING_UTILITY,
      HealthWorkoutActivityType.CALISTHENICS,
      HealthWorkoutActivityType.CIRCUIT_TRAINING,
      HealthWorkoutActivityType.CROSS_FIT,
      HealthWorkoutActivityType.DANCING,
      HealthWorkoutActivityType.DIVING,
      HealthWorkoutActivityType.ELEVATOR,
      HealthWorkoutActivityType.ERGOMETER,
      HealthWorkoutActivityType.ESCALATOR,
      HealthWorkoutActivityType.FRISBEE_DISC,
      HealthWorkoutActivityType.GARDENING,
      HealthWorkoutActivityType.GUIDED_BREATHING,
      HealthWorkoutActivityType.HORSEBACK_RIDING,
      HealthWorkoutActivityType.HOUSEWORK,
      HealthWorkoutActivityType.INTERVAL_TRAINING,
      HealthWorkoutActivityType.IN_VEHICLE,
      HealthWorkoutActivityType.ICE_SKATING,
      HealthWorkoutActivityType.KAYAKING,
      HealthWorkoutActivityType.KETTLEBELL_TRAINING,
      HealthWorkoutActivityType.KICK_SCOOTER,
      HealthWorkoutActivityType.KITE_SURFING,
      HealthWorkoutActivityType.MEDITATION,
      HealthWorkoutActivityType.MIXED_MARTIAL_ARTS,
      HealthWorkoutActivityType.P90X,
      HealthWorkoutActivityType.PARAGLIDING,
      HealthWorkoutActivityType.POLO,
      HealthWorkoutActivityType.ROCK_CLIMBING,
      HealthWorkoutActivityType.ROWING_MACHINE,
      HealthWorkoutActivityType.RUNNING_JOGGING,
      HealthWorkoutActivityType.RUNNING_SAND,
      HealthWorkoutActivityType.RUNNING_TREADMILL,
      HealthWorkoutActivityType.SCUBA_DIVING,
      HealthWorkoutActivityType.SKATING_CROSS,
      HealthWorkoutActivityType.SKATING_INDOOR,
      HealthWorkoutActivityType.SKATING_INLINE,
      HealthWorkoutActivityType.SKIING,
      HealthWorkoutActivityType.SKIING_BACK_COUNTRY,
      HealthWorkoutActivityType.SKIING_KITE,
      HealthWorkoutActivityType.SKIING_ROLLER,
      HealthWorkoutActivityType.SLEDDING,
      HealthWorkoutActivityType.SNOWMOBILE,
      HealthWorkoutActivityType.SNOWSHOEING,
      HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE,
      HealthWorkoutActivityType.STANDUP_PADDLEBOARDING,
      HealthWorkoutActivityType.STILL,
      HealthWorkoutActivityType.STRENGTH_TRAINING,
      HealthWorkoutActivityType.SURFING,
      HealthWorkoutActivityType.SWIMMING_OPEN_WATER,
      HealthWorkoutActivityType.SWIMMING_POOL,
      HealthWorkoutActivityType.TEAM_SPORTS,
      HealthWorkoutActivityType.TILTING,
      HealthWorkoutActivityType.VOLLEYBALL_BEACH,
      HealthWorkoutActivityType.VOLLEYBALL_INDOOR,
      HealthWorkoutActivityType.WAKEBOARDING,
      HealthWorkoutActivityType.WALKING_FITNESS,
      HealthWorkoutActivityType.WALKING_NORDIC,
      HealthWorkoutActivityType.WALKING_STROLLER,
      HealthWorkoutActivityType.WALKING_TREADMILL,
      HealthWorkoutActivityType.WEIGHTLIFTING,
      HealthWorkoutActivityType.WHEELCHAIR,
      HealthWorkoutActivityType.WINDSURFING,
      HealthWorkoutActivityType.ZUMBA,
      HealthWorkoutActivityType.OTHER,
    }.contains(type);
  }
}
