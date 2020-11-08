library activity_recognition;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:foreground_service/foreground_service.dart';

part 'package:activity_recognition_flutter/src/ar_channel.dart';
part 'package:activity_recognition_flutter/src/ar_domain.dart';
part 'package:activity_recognition_flutter/src/ar_foreground.dart';

class ActivityRecognition {
  /// Requests continuous [Activity] updates.
  ///
  /// The Stream will output the *most probable* [Activity].
  static Stream<Activity> activityUpdates() => _activityChannel.activityUpdates;

  static final _activityChannel = _ActivityChannel();
}
