part of weather_library;

/// Safely unpack a double value from a [Map] object.
int _unpackInt(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      return M[k] + 0;
    }
  }
  return 0;
}

/// Safely unpack a double value from a [Map] object.
double _unpackDouble(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      return M[k] + 0.0;
    }
  }
  return 0.0;
}

/// Safely unpack a string value from a [Map] object.
String _unpackString(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      return M[k];
    }
  }
  return "";
}

/// Safely unpacks a unix timestamp from a [Map] object,
/// i.e. an integer value of milliseconds and converts this to a [DateTime] object.
DateTime _unpackDate(Map<String, dynamic> M, String k) {
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
Temperature _unpackTemperature(Map<String, dynamic> M, String k) {
  double kelvin = _unpackDouble(M, k);
  return Temperature(kelvin);
}
