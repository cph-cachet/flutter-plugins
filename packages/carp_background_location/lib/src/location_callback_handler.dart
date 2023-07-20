part of carp_background_location;

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async =>
      await LocationServiceRepository().init(params);

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async =>
      await LocationServiceRepository().dispose();

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async =>
      await LocationServiceRepository().callback(locationDto);

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {}
}
