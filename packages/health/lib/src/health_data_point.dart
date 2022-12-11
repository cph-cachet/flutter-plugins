part of health;

class HealthDataPoint extends Equatable {
  final _map = <String, dynamic>{};

  dynamic operator [](String key) => _map[key];
  dynamic get(String key) => _map[key];

  void operator []=(String key, dynamic value) => _map[key] = value;
  void addAll(Map<String, dynamic> other) => _map.addAll(other);

  Map<String, dynamic> toJson() => _map;

  @override
  List<Object?> get props {
    try {
      final str = json.encode(_map);
      return [str];
    }
    catch (e) {
      // cannot convert to json. Invalid dataPoint
      return [];
    }
  }
}