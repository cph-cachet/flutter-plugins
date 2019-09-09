import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esense_flutter/esense_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('esense_flutter');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await EsenseFlutter.platformVersion, '42');
  });
}
