import 'package:flutter_test/flutter_test.dart';
import 'package:app_usage/app_usage.dart';

void main() {
//  const MethodChannel channel = MethodChannel('app_usage');
//
//  TestWidgetsFlutterBinding.ensureInitialized();
//
//  setUp(() {
//    channel.setMockMethodCallHandler((MethodCall methodCall) async {
//      return '42';
//    });
//  });
//
//  tearDown(() {
//    channel.setMockMethodCallHandler(null);
//  });

  test('Parse app usage info', () async {
    AppUsageInfo info = AppUsageInfo('com.publisher.app_name', 123,
        DateTime(2020, 01, 01), DateTime(2020, 01, 02));
    print(info);
  });
}
