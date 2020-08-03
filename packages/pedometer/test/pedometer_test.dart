import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedometer/pedometer.dart';

void main() {
  const MethodChannel channel = MethodChannel('pedometer');

  TestWidgetsFlutterBinding.ensureInitialized();
}