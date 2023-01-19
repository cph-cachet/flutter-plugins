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
///  * cleaning up duplicate data points via the [removeDuplicates] method.
class HealthFactory {
  static const EventChannel _logsChannel = const EventChannel('flutter_health_logs_channel');
  static const MethodChannel _channel = MethodChannel('flutter_health');
  String? _deviceId;
  final _deviceInfo = DeviceInfoPlugin();
  HealthLogger? _logger;

  static PlatformType _platformType = Platform.isAndroid ? PlatformType.ANDROID : PlatformType.IOS;

  /// Check if a given data type is available on the platform
  bool isDataTypeAvailable(HealthDataType dataType) => _platformType == PlatformType.ANDROID
      ? _dataTypeKeysAndroid.contains(dataType)
      : _dataTypeKeysIOS.contains(dataType);

  void setLogger(HealthLogger logger) {
    if (_logger == null) {
      _setLogsChannelListener();
    }
    _logger = logger;
  }

  void _setLogsChannelListener() {
    _logsChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onEvent(Object? event) {
    if (event == null) return;
    _logger?.i(event.toString());
  }

  void _onError(Object error) {
    _logger?.e(error.toString());
  }

  /// Determines if the data types have been granted with the specified access rights.
  ///
  /// Returns:
  ///
  /// * true - if all of the data types have been granted with the specified access rights.
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
  ///   this method can only return null to represent an undetermined status, if it is called on iOS
  ///   with a READ or READ_WRITE access.
  ///
  ///   On Android, this function returns true or false, depending on whether the specified access right has been granted.
  static Future<bool?> hasPermissions(List<HealthDataType> types, {List<HealthDataAccess>? permissions}) async {
    if (permissions != null && permissions.length != types.length)
      throw ArgumentError("The lists of types and permissions must be of same length.");

    final mTypes = List<HealthDataType>.from(types, growable: true);
    final mPermissions = permissions == null
        ? List<int>.filled(types.length, HealthDataAccess.READ.index, growable: true)
        : permissions.map((permission) => permission.index).toList();

    /// On Android, if BMI is requested, then also ask for weight and height
    if (_platformType == PlatformType.ANDROID) _handleBMI(mTypes, mPermissions);

    return await _channel.invokeMethod('hasPermissions', {
      "types": mTypes.map((type) => type.name).toList(),
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
      throw ArgumentError('The length of [types] must be same as that of [permissions].');
    }

    for (var dataType in types) {
      // If not implemented on platform, throw an exception
      if (!isDataTypeAvailable(dataType)) {
        throw HealthException(dataType, 'Not available on platform $_platformType');
      }
    }

    final mTypes = List<HealthDataType>.from(types, growable: true);
    final mPermissions = permissions == null
        ? List<int>.filled(types.length, HealthDataAccess.READ.index, growable: true)
        : permissions.map((permission) => permission.index).toList();

    // on Android, if BMI is requested, then also ask for weight and height
    if (_platformType == PlatformType.ANDROID) {
      _handleBMI(mTypes, mPermissions);

      if (mTypes.contains(HealthDataType.WORKOUT) ||
          mTypes.contains(HealthDataType.STEPS) ||
          mTypes.contains(HealthDataType.EXERCISE_TIME)) {
        // If we are trying to read Step Count, Workout, Sleep or other data that requires
        // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
        // This requires a special request authorization call.
        //
        // The location permission is requested for Workouts using the Distance information.
        final activityRecognitionPermissionStatus = await Permission.activityRecognition.request();
        final locationPermissionStatus = await Permission.location.request();

        if (activityRecognitionPermissionStatus != PermissionStatus.granted ||
            locationPermissionStatus != PermissionStatus.granted) {
          return false;
        }
      }
    }

    List<String> keys = mTypes.map((e) => e.name).toList();
    final bool? isAuthorized =
        await _channel.invokeMethod('requestAuthorization', {'types': keys, "permissions": mPermissions});
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
  /// Values for Sleep and Headache are ignored and will be automatically assigned the corresponding value.
  Future<bool> writeHealthData(
    double value,
    HealthDataType type,
    DateTime startTime,
    DateTime endTime, {
    HealthDataUnit? unit,
  }) async {
    if (type == HealthDataType.WORKOUT)
      throw ArgumentError("Adding workouts should be done using the writeWorkoutData method.");
    if (startTime.isAfter(endTime)) throw ArgumentError("startTime must be equal or earlier than endTime");
    if ([
      HealthDataType.HIGH_HEART_RATE_EVENT,
      HealthDataType.LOW_HEART_RATE_EVENT,
      HealthDataType.IRREGULAR_HEART_RATE_EVENT
    ].contains(type)) throw ArgumentError("$type - iOS does not support writing this data type in HealthKit");

    // Assign default unit if not specified
    unit ??= _dataTypeToUnit[type]!;

    // Align values to type in cases where the type defines the value.
    // E.g. SLEEP_IN_BED should have value 0
    if (type == HealthDataType.SLEEP ||
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
      'startTimeSec': startTime.millisecondsSinceEpoch ~/ 1000,
      'endTimeSec': endTime.millisecondsSinceEpoch ~/ 1000,
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
  Future<bool> writeAudiogram(List<double> frequencies, List<double> leftEarSensitivities,
      List<double> rightEarSensitivities, DateTime startTime, DateTime endTime,
      {Map<String, dynamic>? metadata}) async {
    if (frequencies.isEmpty || leftEarSensitivities.isEmpty || rightEarSensitivities.isEmpty)
      throw ArgumentError("frequencies, leftEarSensitivities and rightEarSensitivities can't be empty");
    if (frequencies.length != leftEarSensitivities.length ||
        rightEarSensitivities.length != leftEarSensitivities.length)
      throw ArgumentError("frequencies, leftEarSensitivities and rightEarSensitivities need to be of the same length");
    if (startTime.isAfter(endTime)) throw ArgumentError("startTime must be equal or earlier than endTime");
    if (_platformType == PlatformType.ANDROID) throw UnsupportedError("writeAudiogram is not supported on Android");
    Map<String, dynamic> args = {
      'frequencies': frequencies,
      'leftEarSensitivities': leftEarSensitivities,
      'rightEarSensitivities': rightEarSensitivities,
      'dataTypeKey': HealthDataType.AUDIOGRAM.name,
      'startTimeSec': startTime.millisecondsSinceEpoch ~/ 1000,
      'endTimeSec': endTime.millisecondsSinceEpoch ~/ 1000,
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

    return dataPoints;
  }

  /// Prepares a query, i.e. checks if the types are available, etc.
  Future<List<HealthDataPoint>> _prepareQuery(DateTime startTime, DateTime endTime, HealthDataType dataType) async {
    // Ask for device ID only once
    _deviceId ??= _platformType == PlatformType.ANDROID
        ? (await _deviceInfo.androidInfo).id
        : (await _deviceInfo.iosInfo).identifierForVendor;

    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw HealthException(dataType, 'Not available on platform $_platformType');
    }

    return await _dataQuery(startTime, endTime, dataType);
  }

  /// The main function for fetching health data
  Future<List<HealthDataPoint>> _dataQuery(DateTime startTime, DateTime endTime, HealthDataType dataType) async {
    final args = <String, dynamic>{
      'dataTypeKey': dataType.name,
      'dataUnitKey': _dataTypeToUnit[dataType]!.name,
      'startTimeSec': startTime.millisecondsSinceEpoch ~/ 1000,
      'endTimeSec': endTime.millisecondsSinceEpoch ~/ 1000,
    };
    List<Map>? fetchedDataPoints = await _channel.invokeListMethod('getData', args);
    if (fetchedDataPoints != null) {
      return _parse(dataType: dataType, dataPoints: fetchedDataPoints);
    } else {
      return <HealthDataPoint>[];
    }
  }

  List<HealthDataPoint> _parse({required HealthDataType dataType, required List<Map> dataPoints}) {
    final healthDataPoints = dataPoints.map((e) => e.cast<String, dynamic>()).toList();

    final dataToAdd = {
      "dataType": dataType.name,
      "deviceId": "$_deviceId",
    };

    healthDataPoints.forEach((element) {
      element.addAll(dataToAdd);
    });

    return healthDataPoints;
  }

  /// Get the total number of steps within a specific time period.
  /// Returns null if not successful.
  ///
  /// Is a fix according to https://stackoverflow.com/questions/29414386/step-count-retrieved-through-google-fit-api-does-not-match-step-count-displayed/29415091#29415091
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final args = <String, dynamic>{
      'startTimeSec': startTime.millisecondsSinceEpoch ~/ 1000,
      'endTimeSec': endTime.millisecondsSinceEpoch ~/ 1000,
    };
    final stepsCount = await _channel.invokeMethod<int?>(
      'getTotalStepsInInterval',
      args,
    );
    return stepsCount;
  }

  int _alignValue(HealthDataType type) {
    switch (type) {
      case HealthDataType.SLEEP:
        return 0;
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
      throw HealthException(activityType, "Workout activity type $activityType is not supported on iOS");
    } else if (!_isOnAndroid(activityType)) {
      throw HealthException(activityType, "Workout activity type $activityType is not supported on Android");
    }
    final args = <String, dynamic>{
      'activityType': activityType.name,
      'startTimeSec': start.millisecondsSinceEpoch ~/ 1000,
      'endTimeSec': end.millisecondsSinceEpoch ~/ 1000,
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
      HealthWorkoutActivityType.AEROBICS,
      HealthWorkoutActivityType.BIATHLON,
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
      HealthWorkoutActivityType.RUNNING_JOGGING,
      HealthWorkoutActivityType.RUNNING_SAND,
      HealthWorkoutActivityType.RUNNING_TREADMILL,
      HealthWorkoutActivityType.SCUBA_DIVING,
      HealthWorkoutActivityType.SKATING_CROSS,
      HealthWorkoutActivityType.SKATING_INDOOR,
      HealthWorkoutActivityType.SKATING_INLINE,
      HealthWorkoutActivityType.SKIING_BACK_COUNTRY,
      HealthWorkoutActivityType.SKIING_KITE,
      HealthWorkoutActivityType.SKIING_ROLLER,
      HealthWorkoutActivityType.SLEDDING,
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
