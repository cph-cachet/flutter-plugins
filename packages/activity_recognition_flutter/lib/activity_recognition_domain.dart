part of activity_recognition;

/// The different types of activities which can be detected.
/// These types is identical to the types detected on Android
/// and iOS types are mapped to these.
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
  // Android
  'IN_VEHICLE': ActivityType.IN_VEHICLE,
  'ON_BICYCLE': ActivityType.ON_BICYCLE,
  'ON_FOOT': ActivityType.ON_FOOT,
  'RUNNING': ActivityType.RUNNING,
  'STILL': ActivityType.STILL,
  'TILTING': ActivityType.TILTING,
  'UNKNOWN': ActivityType.UNKNOWN,
  'WALKING': ActivityType.WALKING,

  // iOS
  'automotive': ActivityType.IN_VEHICLE,
  'cycling': ActivityType.ON_BICYCLE,
  'running': ActivityType.RUNNING,
  'stationary': ActivityType.STILL,
  'unknown': ActivityType.UNKNOWN,
  'walking': ActivityType.WALKING,
};

/// Represents an activity event detected on the phone.
class ActivityEvent {
  /// The type of activity.
  ActivityType type;

  /// The confidence of the dection in percentage.
  int confidence;

  /// The timestamp when detected.
  late DateTime timeStamp;

  /// The type of activity as a String.
  String get typeString => type.toString().split('.').last;

  ActivityEvent(this.type, this.confidence) {
    this.timeStamp = DateTime.now();
  }

  factory ActivityEvent.unknown() => ActivityEvent(ActivityType.UNKNOWN, 100);

  /// Create an [ActivityEvent] based on the string format `type,confidence`.
  factory ActivityEvent.fromString(String string) {
    List<String> tokens = string.split(",");
    if (tokens.length < 2) return ActivityEvent.unknown();

    ActivityType type = ActivityType.UNKNOWN;
    if (_activityMap.containsKey(tokens.first)) {
      type = _activityMap[tokens.first]!;
    }
    int conf = int.tryParse(tokens.last)!;

    return ActivityEvent(type, conf);
  }

  @override
  String toString() => 'Activity - type: $typeString, confidence: $confidence%';
}
