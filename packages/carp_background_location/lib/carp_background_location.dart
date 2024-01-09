library carp_background_location;

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
// import 'dart:math';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';

export 'package:background_locator_2/location_dto.dart';
export 'package:background_locator_2/settings/android_settings.dart';
export 'package:background_locator_2/settings/ios_settings.dart';
export 'package:background_locator_2/settings/locator_settings.dart';

part 'src/location_callback_handler.dart';
part 'src/location_service_repository.dart';
part 'src/location_manager.dart';
