part of '../mobility_features.dart';

/// Returns an [Iterable] of [List]s where the nth element in the returned
/// iterable contains the nth element from every Iterable in [iterables]. The
/// returned Iterable is as long as the shortest Iterable in the argument. If
/// [iterables] is empty, it returns an empty list.
Iterable<List<T>> zip<T>(Iterable<Iterable<T>> iterables) sync* {
  if (iterables.isEmpty) return;
  final iterators = iterables.map((e) => e.iterator).toList(growable: false);
  while (iterators.every((e) => e.moveNext())) {
    yield iterators.map((e) => e.current).toList(growable: false);
  }
}

/// Convert from degrees to radians
extension on double {
  double get radiansFromDegrees => this * (pi / 180.0);
}

Iterable<int> range(int low, int high) sync* {
  for (int i = low; i < high; ++i) {
    yield i;
  }
}

extension CompareDates on DateTime {
  bool geq(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }

  bool leq(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }

  DateTime get midnight {
    return DateTime(year, month, day);
  }
}

int argmaxDouble(List<double> list) {
  double maxVal = -double.infinity;
  int i = 0;

  for (int j = 0; j < list.length; j++) {
    if (list[j] > maxVal) {
      maxVal = list[j];
      i = j;
    }
  }
  return i;
}

int argmaxInt(List<int> list) {
  int maxVal = -2147483648;
  int i = 0;

  for (int j = 0; j < list.length; j++) {
    if (list[j] > maxVal) {
      maxVal = list[j];
      i = j;
    }
  }
  return i;
}

List<List<double>> zeroMatrix(int rows, int cols) =>
    List.generate(rows, (_) => List<double>.filled(cols, 0.0));

List<Stop> _mergeStops(List<Stop> stops) {
  List<Stop> merged = [];
  if (stops.length < 2) return stops;

  // Should be applied after places have been found
  List<Stop> toMerge = [];

  void merge() {
    if (toMerge.isEmpty) return;
    GeoLocation geoLocation = _computeCentroid(toMerge);
    DateTime arr = toMerge.first.arrival;
    DateTime dep = toMerge.last.departure;
    Stop s = Stop(geoLocation, arr, dep, toMerge.first.placeId);
    merged.add(s);
    toMerge = [];
  }

  for (Stop stop in stops) {
    // If stop is noisy, just add it to the merged list, don't do anything to it
    if (stop.placeId == -1) {
      merged.add(stop);
    } else {
      // If no stops to merge, we cannot merge and we therefore add the current
      // stop and go to the next one
      if (toMerge.isEmpty) {
        toMerge.add(stop);
      }

      // Otherwise check if we should add it or merge
      else {
        if (stop.placeId != toMerge.last.placeId) {
          merge();
        }
        toMerge.add(stop);
      }
    }
  }

  // Merge remaining stops in the toMerge list
  merge();

  return merged;
}
