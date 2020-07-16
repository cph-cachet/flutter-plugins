import 'dart:ui';

import 'package:flutter/material.dart';

import 'keys.dart';

class LocationAccuracy {
  const LocationAccuracy._internal(this.value);

  final int value;

  static const POWERSAVE = LocationAccuracy._internal(0);
  static const LOW = LocationAccuracy._internal(1);
  static const BALANCED = LocationAccuracy._internal(2);
  static const HIGH = LocationAccuracy._internal(3);
  static const NAVIGATION = LocationAccuracy._internal(4);
}

class LocationSettings {
  /// [accuracy], The accuracy of location, Default is max accuracy NAVIGATION
  final LocationAccuracy accuracy;
  final int interval; //seconds
  final double distanceFilter;
  final String notificationChannelName;
  final String notificationTitle;
  final String notificationMsg;
  final String notificationIcon;
  final Color notificationIconColor;
  final int wakeLockTime; //minutes
  final bool autoStop;

  /// [accuracy] The accuracy of location, Default is max accuracy NAVIGATION.
  ///
  /// [interval] Interval of retrieving location update in second. Only applies for android. Default is 5 second.
  ///
  /// [distanceFilter] distance in meter to trigger location update, Default is 0 meter.
  ///
  /// [notificationTitle] Title of the notification. Only applies for android. Default is 'Start Location Tracking'.
  ///
  /// [notificationMsg] Message of notification. Only applies for android. Default is 'Track location in background'.
  ///
  /// [notificationIcon] Icon name for notification. Only applies for android. The icon should be in 'mipmap' Directory.
  /// Default is app icon. Icon must comply to android rules to be displayed (transparent background and black/white shape)
  ///
  /// [notificationIconColor] Icon color for notification from notification drawer. Only applies for android. Default color is grey.
  ///
  /// [wakeLockTime] Time for living service in background in meter. Only applies in android. Default is 60 minute.
  ///
  /// [autoStop] If true locator will stop as soon as app goes to background.
  LocationSettings(
      {this.accuracy = LocationAccuracy.NAVIGATION,
      this.interval = 5,
      this.distanceFilter = 0,
      this.notificationChannelName = 'Location tracking',
      this.notificationTitle = 'Start Location Tracking',
      this.notificationMsg = 'Track location in background',
      this.notificationIcon = '',
      this.notificationIconColor = Colors.grey,
      this.wakeLockTime = 60,
      this.autoStop = false});

  Map<String, dynamic> toMap() {
    return {
      Keys.ARG_ACCURACY: accuracy.value,
      Keys.ARG_INTERVAL: interval,
      Keys.ARG_DISTANCE_FILTER: distanceFilter,
      Keys.ARG_NOTIFICATION_CHANNEL_NAME: notificationChannelName,
      Keys.ARG_NOTIFICATION_TITLE: notificationTitle,
      Keys.ARG_NOTIFICATION_MSG: notificationMsg,
      Keys.ARG_NOTIFICATION_ICON: notificationIcon,
      Keys.ARG_NOTIFICATION_ICON_COLOR: notificationIconColor?.value,
      Keys.ARG_WAKE_LOCK_TIME: wakeLockTime,
      Keys.ARG_AUTO_STOP: autoStop,
    };
  }
}
