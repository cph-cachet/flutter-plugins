import 'package:mocktail/mocktail.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MockDeviceInfoPlugin extends Mock implements DeviceInfoPlugin {
  @override
  Future<AndroidDeviceInfo> get androidInfo =>
      Future.value(AndroidDeviceInfo.fromMap({
        'id': 'mock-android-id',
        'version': {
           'baseOS': 'mock-baseOS',
          'codename': 'mock-codename',
          'incremental': 'mock-incremental',
          'previewSdkInt': 23,
          'release': 'mock-release',
          'sdkInt': 30,
          'securityPatch': 'mock-securityPatch',
        },
       'board': 'mock-board',
        'bootloader': 'mock-bootloader',
        'brand': 'mock-brand',
        'device': 'mock-device',
        'display': 'mock-display',
        'fingerprint': 'mock-fingerprint',
        'hardware': 'mock-hardware',
        'host': 'mock-host',
        'manufacturer': 'mock-manufacturer',
        'model': 'mock-model',
        'product': 'mock-product',
        'supported32BitAbis': <String>[],
        'supported64BitAbis': <String>[],
        'supportedAbis': <String>[],
        'tags': 'mock-tags',
        'type': 'mock-type',
        'isPhysicalDevice': true,
         'systemFeatures': <String>[],
         'serialNumber': 'mock-serial',
         'isLowRamDevice': false,
      }));


  @override
    Future<IosDeviceInfo> get iosInfo => Future.value(IosDeviceInfo.fromMap({
          'name': 'mock-ios-name',
          'systemName': 'mock-ios-systemName',
          'systemVersion': '16.0',
          'model': 'mock-ios-model',
          'modelName': 'mock-ios-modelName',
          'localizedModel': 'mock-ios-localizedModel',
          'identifierForVendor': 'mock-ios-id',
          'isPhysicalDevice': true,
          'isiOSAppOnMac': false,
          'utsname': {
            'sysname': 'mock-ios-sysname',
            'nodename': 'mock-ios-nodename',
            'release': 'mock-ios-release',
            'version': 'mock-ios-version',
            'machine': 'mock-ios-machine',
           },
        }));
}