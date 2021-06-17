library carp_background_location;

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'dart:math';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';

export 'package:background_locator/location_dto.dart';
export 'package:background_locator/settings/locator_settings.dart';

part 'src/location_callback_handler.dart';
part 'src/location_service_repository.dart';
part 'src/location_manager.dart';
