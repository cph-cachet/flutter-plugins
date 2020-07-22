import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';

void main() {
  test('Parsing test', () {
    List<String> data = [
      'stationary',
      'walking',
      'running',
      'ON_FOOT',
      'IN_VEHICLE',
      '123'
    ];

    for (String d in data) {
      Activity a = Activity.fromJson({'type': d, 'confidence': 100});
      print(a);
    }
  });
}
