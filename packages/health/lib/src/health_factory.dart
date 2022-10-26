part of health;

enum AndroidDataSource { HealthConnect, GoogleFit }

/// Main class for the Plugin.
///
/// The plugin supports:
///
///  * handling permissions to access health data using the [hasPermissions],
///    [requestPermissions], [requestAuthorization], [revokePermissions] methods.
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
      "types": mTypes.map((type) => _enumToString(type)).toList(),
      "permissions": mPermissions,
    });
    //}
  }

  /// Request permissions.
  ///
  /// If you're using more than one [HealthDataType] it's advised to call
  /// [requestPermissions] with all the data types once. Otherwise iOS HealthKit
  /// will ask to approve every permission one by one in separate screens.
  static Future<bool?> requestPermissions(
    List<HealthDataType> types,
  ) async {
    return await _channel.invokeMethod('requestPermissions', {
      "types": types.map((type) => _enumToString(type)).toList(),
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

    if (_platformType != PlatformType.ANDROID &&
        _platformType != PlatformType.IOS) {
      return false;
    }

    List<HealthDataType> usableTypes = [];
    List<HealthDataAccess>? usablePermissions = permissions == null ? null : [];

    var platformDataTypeKeys = _platformType == PlatformType.ANDROID
        ? _dataTypeKeysAndroid
        : _dataTypeKeysIOS;

    // Only use supplied types and permissions if they are valid for the current platform
    for (var i = 0; i < types.length; i++) {
      var typeToCheck = types[i];

      if (platformDataTypeKeys.contains(typeToCheck)) {
        usableTypes.add(typeToCheck);
        if (permissions != null && usablePermissions != null) {
          usablePermissions.add(permissions[i]);
        }
      }
    }

    if (usableTypes.isEmpty) {
      return false;
    }

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
      DateTime startDate, DateTime endDate) async {
    List<HealthDataPoint> heights =
        await _prepareQuery(startDate, endDate, HealthDataType.HEIGHT);

    if (heights.isEmpty) {
      return [];
    }

    List<HealthDataPoint> weights =
        await _prepareQuery(startDate, endDate, HealthDataType.WEIGHT);

    double h = heights.last.value.toDouble();

    const dataType = HealthDataType.BODY_MASS_INDEX;
    final unit = _dataTypeToUnit[dataType]!;

    final bmiHealthPoints = <HealthDataPoint>[];
    for (var i = 0; i < weights.length; i++) {
      final bmiValue = weights[i].value.toDouble() / (h * h);
      final x = HealthDataPoint(bmiValue, dataType, unit, weights[i].dateFrom,
          weights[i].dateTo, _platformType, _deviceId!, '', '');

      bmiHealthPoints.add(x);
    }
    return bmiHealthPoints;
  }

  ///And also how to handle [HealthConnectNutrition]
  ///
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
  Future<bool> writeHealthData(
    HealthDataType type, {
    DateTime? startTime,
    DateTime? endTime,
    double? value,
  }) async {
    if (startTime == null) throw ArgumentError("startTime must be not null");
    if (endTime == null) throw ArgumentError("endTime must be not null");
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");

    Map<String, dynamic> args = {
      'value': value,
      'dataTypeKey': _enumToString(type),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch
    };
    bool? success = await _channel.invokeMethod('writeData', args);
    return success ?? false;
  }

  Future<bool> writeFoodData(
      List<Map> foodList, DateTime startTime, DateTime endTime,
      {bool overwrite = false}) async {
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");
    Map<String, dynamic> args = {
      'foodList': foodList,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'overwrite': overwrite
    };
    bool? success = await _channel.invokeMethod('writeFoodData', args);
    return success ?? false;
  }

  /// Saves health data into Apple Health or Google Fit.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [type] - the value's HealthDataType
  /// * [startTime] - the start time from which to delete data of [type].
  ///   + It must be equal to or earlier than [endTime].
  /// * [endTime] - the end time from which to delete data of [type].
  ///   + It must be equal to or later than [startTime].
  ///   + Simply set [endTime] equal to [startTime] if the [value] is measured only at a specific point in time.
  ///
  Future<bool> deleteHealthData(
      HealthDataType type, DateTime startTime, DateTime endTime) async {
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");
    Map<String, dynamic> args = {
      'dataTypeKey': _enumToString(type),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
    };
    bool? success = await _channel.invokeMethod('deleteData', args);
    return success ?? false;
  }

  Future<bool> deleteFoodData(DateTime startTime, DateTime endTime) async {
    if (startTime.isAfter(endTime))
      throw ArgumentError("startTime must be equal or earlier than endTime");
    Map<String, dynamic> args = {
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
    };
    bool? success = await _channel.invokeMethod('deleteFoodData', args);
    return success ?? false;
  }

  /// Fetch a list of health data points based on [types].
  Future<List<HealthDataPoint>> getHealthDataFromTypes(
    DateTime startDate,
    DateTime endDate,
    List<HealthDataType> types,
  ) async {
    List<HealthDataPoint> dataPoints = [];

    for (var type in types) {
      final result = await _prepareQuery(startDate, endDate, type);
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
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
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
      return _computeAndroidBMI(startDate, endDate);
    }
    return await _dataQuery(startDate, endDate, dataType);
  }

  /// The main function for fetching health data
  Future<List<HealthDataPoint>> _dataQuery(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    final args = <String, dynamic>{
      'dataTypeKey': _enumToString(dataType),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
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
      final num value = e['value'];
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
    final unique = <HealthDataPoint>[];

    for (var p in points) {
      var seenBefore = false;
      for (var s in unique) {
        if (s == p) {
          seenBefore = true;
          break;
        }
      }
      if (!seenBefore) {
        unique.add(p);
      }
    }
    return unique;
  }

  /// Get the total numbner of steps within a specific time period.
  /// Returns null if not successful.
  ///
  /// Is a fix according to https://stackoverflow.com/questions/29414386/step-count-retrieved-through-google-fit-api-does-not-match-step-count-displayed/29415091#29415091
  Future<int?> getTotalStepsInInterval(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final args = <String, dynamic>{
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };
    final stepsCount = await _channel.invokeMethod<int?>(
      'getTotalStepsInInterval',
      args,
    );
    return stepsCount;
  }

  /// To Check Health Connect app is installed on the device.
  /// Without the app, permissions won't work.
  Future<bool> isHealthConnectAvailable() async {
    final bool? isAvailable = await _channel.invokeMethod(
      'isHealthConnectAvailable',
    );
    return isAvailable ?? false;
  }

  /// Determines if the data types have been granted with the specified access rights.
  /// To Check Health Connect Granted Permission
  Future<bool> hasHCPermissions(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    if (permissions != null && permissions.length != types.length) {
      throw ArgumentError(
          'The length of [types] must be same as that of [permissions].');
    }

    for (var i = 0; i < types.length; i++) {
      if (types[i] != HealthDataType.WEIGHT &&
          types[i] != HealthDataType.BODY_FAT_PERCENTAGE &&
          types[i] != HealthDataType.NUTRITION) {
        var tempType = types[i];
        types.removeAt(i);
        permissions?.removeAt(i);
        throw ArgumentError("$tempType type not supported");
      }
    }

    if (_platformType != PlatformType.ANDROID) {
      return false;
    }

    final mTypes = List<HealthDataType>.from(types, growable: true);
    final mPermissions = permissions == null
        ? List<int>.filled(types.length, HealthDataAccess.READ.index,
            growable: true)
        : permissions.map((permission) => permission.index).toList();

    List<String> keys = mTypes.map((e) => _enumToString(e)).toList();
    final bool? isAuthorized = await _channel.invokeMethod(
        'hasPermissionsHealthConnect',
        {'types': keys, "permissions": mPermissions});
    return isAuthorized ?? false;
  }

  Future<bool> requestHCPermissions(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    if (permissions != null && permissions.length != types.length) {
      throw ArgumentError(
          'The length of [types] must be same as that of [permissions].');
    }

    if (_platformType != PlatformType.ANDROID) {
      return false;
    }

    final mTypes = List<HealthDataType>.from(types, growable: true);
    final mPermissions = permissions == null
        ? List<int>.filled(types.length, HealthDataAccess.READ.index,
            growable: true)
        : permissions.map((permission) => permission.index).toList();

    List<String> keys = mTypes.map((e) => _enumToString(e)).toList();
    final bool? isAuthorized = await _channel.invokeMethod(
        'requestHealthConnectPermission',
        {'types': keys, "permissions": mPermissions});
    print("$isAuthorized");
    return isAuthorized ?? false;
  }

  /// Saves health data into Health Connect.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [value] - the health data's value in double
  /// * [type] - the value's HealthDataType
  /// * [currentTime] - the currentTime when this [value] is measured.
  Future<bool> writeHCData(
    HealthDataType type, {
    required double value,
    required DateTime currentTime,
  }) async {
    if (_platformType != PlatformType.ANDROID) {
      throw ArgumentError("This operation is not supported for $_platformType");
    }
    if (type != HealthDataType.WEIGHT &&
        type != HealthDataType.BODY_FAT_PERCENTAGE)
      throw ArgumentError(
          "This datatype is not supported for HealthConnect yet");

    Map<String, dynamic> args = {
      'value': value,
      'dataTypeKey': _enumToString(type),
      'currentTime':
          DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(currentTime).toString(),
    };
    bool? success = await _channel.invokeMethod('writeDataHealthConnect', args);
    return success ?? false;
  }

  /// Saves health data into Health Connect.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  /// * [nutrition] - the health data's value in [HealthConnectNutrition]
  Future<bool> writeHCNutrition({
    required HealthConnectNutrition nutrition,
  }) async {
    if (_platformType != PlatformType.ANDROID) {
      throw ArgumentError("This operation is not supported for $_platformType");
    }

    if (nutrition.startTime.compareTo(nutrition.endTime) == 0)
      throw ArgumentError("startTime must be earlier than endTime");
    if (nutrition.startTime.isAfter(nutrition.endTime))
      throw ArgumentError("startTime must be earlier than endTime");
    Map<String, dynamic> args = {
      'value': nutrition.toMap(),
      'dataTypeKey': _enumToString(HealthDataType.NUTRITION),
    };
    bool? success = await _channel.invokeMethod('writeDataHealthConnect', args);
    return success ?? false;
  }

  /// To get Health Connect Data by [HealthTypeData]
  Future<List<HealthConnectData>> getHCData(
    DateTime startDate,
    DateTime endDate,
    HealthDataType type,
  ) async {
    if (_platformType == PlatformType.ANDROID) {
      if (startDate.isAfter(endDate))
        throw ArgumentError("startTime must be equal or earlier than endTime");

      if (startDate == endDate) {
        throw ArgumentError("end time needs be after start time");
      }

      Map<String, dynamic> args = {
        'dataTypeKey': _enumToString(type),
        'startDate':
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startDate).toString(),
        'endDate':
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endDate).toString(),
      };
      var success = await _channel.invokeMethod('getHealthConnectData', args);
      if (success.length > 0) {
        if (type == HealthDataType.WEIGHT) {
          return success.map<HealthConnectWeight>((e) {
            return HealthConnectWeight.fromJson(
                e as Map<dynamic, dynamic>, type);
          }).toList();
        } else if (type == HealthDataType.BODY_FAT_PERCENTAGE) {
          return success.map<HealthConnectBodyFat>((e) {
            return HealthConnectBodyFat.fromJson(
                e as Map<dynamic, dynamic>, type);
          }).toList();
        } else if (type == HealthDataType.NUTRITION) {
          return success.map<HealthConnectNutrition>((e) {
            return HealthConnectNutrition.fromJson(
                e as Map<dynamic, dynamic>, type);
          }).toList();
        }
      }
      return [];
    }
    throw ArgumentError("This method will only work with Android.");
  }

  /// Delete Health Connect entries using [uID] & [type]
  Future<bool> deleteHCData(HealthDataType type, String uID) async {
    if (_platformType == PlatformType.ANDROID) {
      if (uID.isEmpty) throw ArgumentError("uID must be not null");
      Map<String, dynamic> args = {
        'dataTypeKey': _enumToString(type),
        'uID': uID
      };
      var success =
          await _channel.invokeMethod('deleteHealthConnectData', args);
      return success ?? false;
    }
    throw ArgumentError("This method will only work with Android.");
  }

  /// Delete Health Connect entries using [startTime] & [endTime] &[type]
  Future<bool> deleteHCDataByDateRange(
      HealthDataType type, DateTime startTime, DateTime endTime) async {
    if (_platformType == PlatformType.ANDROID) {
      if (startTime.isAfter(endTime))
        throw ArgumentError("startTime must be equal or earlier than endTime");
      Map<String, dynamic> args = {
        'dataTypeKey': _enumToString(type),
        'startTime':
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startTime).toString(),
        'endTime':
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endTime).toString(),
      };
      var success =
          await _channel.invokeMethod('deleteHealthConnectDataByDateRange', args);
      return success ?? false;
    }
    throw ArgumentError("This method will only work with Android.");
  }
}
