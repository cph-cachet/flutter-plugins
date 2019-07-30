import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esense/esense.dart';

void main() {
  const MethodChannel channel = MethodChannel('esense');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PlatformVersion.platformVersion, '42');
  });
}
