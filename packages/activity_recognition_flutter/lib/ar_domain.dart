part of activity_recognition;

enum ActivityType {
  IN_VEHICLE,
  ON_BICYCLE,
  ON_FOOT,
  RUNNING,
  STILL,
  TILTING,
  UNKNOWN,
  WALKING,
  INVALID // Used for parsing errors
}

Map<String, ActivityType> _activityMap = {
  /// Android
  'IN_VEHICLE': ActivityType.IN_VEHICLE,
  'ON_BICYCLE': ActivityType.ON_BICYCLE,
  'ON_FOOT': ActivityType.ON_FOOT,
  'RUNNING': ActivityType.RUNNING,
  'STILL': ActivityType.STILL,
  'TILTING': ActivityType.TILTING,
  'UNKNOWN': ActivityType.UNKNOWN,
  'WALKING': ActivityType.WALKING,

  /// iOS
  'automotive': ActivityType.IN_VEHICLE,
  'cycling': ActivityType.ON_BICYCLE,
  'running': ActivityType.RUNNING,
  'stationary': ActivityType.STILL,
  'unknown': ActivityType.UNKNOWN,
  'walking': ActivityType.WALKING,
};

class ActivityEvent {
  ActivityType _type;
  int _confidence;
  late DateTime _timeStamp;

  ActivityEvent._(this._type, this._confidence) {
    this._timeStamp = DateTime.now();
  }

  factory ActivityEvent.empty() => ActivityEvent._(ActivityType.UNKNOWN, 100);

  factory ActivityEvent.fromJson(String data) {
    debugPrint("Activity event data: $data");
    List<String> tokens = data.split(",");
    if (tokens.length < 2) {
      return ActivityEvent.empty();
    }

    ActivityType type = ActivityType.UNKNOWN;
    if (_activityMap.containsKey(tokens.first)) {
      type = _activityMap[tokens.first]!;
    }
    int conf = int.tryParse(tokens.last)!;

    return ActivityEvent._(type, conf);
  }

  @override
  String toString() {
    String typeString = type.toString().split('.').last;
    return 'Activity: $typeString, (Confidence: $confidence)';
  }

  ActivityType get type => _type;

  DateTime get timeStamp => _timeStamp;

  int get confidence => _confidence;
}
