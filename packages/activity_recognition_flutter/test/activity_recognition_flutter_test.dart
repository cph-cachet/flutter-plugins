import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('activity_recognition_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
