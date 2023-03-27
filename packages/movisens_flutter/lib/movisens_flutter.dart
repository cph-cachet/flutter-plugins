/*
 * Copyright 2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
library movisens_flutter;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';
import 'dart:io' show Platform;

import 'package:rxdart/rxdart.dart';

part 'movisens_utils.dart';
part 'movisens_service.dart';
part 'movisens_device.dart';
part 'movisens_event.dart';
part 'movisens_characteristic.dart';

final _log = Logger("MovisensFlutterLogger");
