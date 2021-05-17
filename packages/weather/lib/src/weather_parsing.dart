part of weather_library;

/// Safely unpack an integer value from a [Map] object.
int? _unpackInt(Map<String, dynamic>? M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      final val = M[k];
      if (val is String) {
        return int.parse(val);
      } else if (val is int) {
        return val;
      }
      return -1;
    }
  }
  return null;
}

/// Safely unpack a double value from a [Map] object.
double? _unpackDouble(Map<String, dynamic>? M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      final val = M[k];
      if (val is String) {
        return double.parse(val);
      } else if (val is num) {
        return val.toDouble();
      }
    }
  }
  return null;
}

/// Safely unpack a string value from a [Map] object.
String? _unpackString(Map<String, dynamic>? M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      return M[k];
    }
  }
  return null;
}

/// Safely unpacks a unix timestamp from a [Map] object,
/// i.e. an integer value of milliseconds and converts this to a [DateTime] object.
DateTime? _unpackDate(Map<String, dynamic>? M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      int millis = M[k] * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  return null;
}

/// Unpacks a [double] value from a [Map] object and converts this to
/// a [Temperature] object.
Temperature _unpackTemperature(Map<String, dynamic>? M, String k) {
  double? kelvin = _unpackDouble(M, k);
  return Temperature(kelvin);
}
