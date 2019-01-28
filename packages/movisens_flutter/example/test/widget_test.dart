// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:movisens_flutter/movisens_flutter.dart';

void main() {
  int weight = 100, height = 180, age = 25;
  String address = '88:6B:0F:82:1D:33', name = 'Sensor 02655';
  UserData userData = new UserData(
      weight, height, Gender.male, age, SensorLocation.chest, address, name);

  print(userData.asMap);
}
