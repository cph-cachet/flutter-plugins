import 'package:test/test.dart';

import 'package:maptest/maptest.dart';

void main() {
  test('adds one to input values', () {
    Map<String, String> m = new Map();
    m["key"] = "someValue";
    m["key2"] = "someValue2";
    m["key3"] = "someValue3";

    print("$m");
  });
}
