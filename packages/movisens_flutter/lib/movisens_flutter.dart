/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
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

// class MovisensFlutter {
//   MovisensFlutter._({Level logLevel = Level.INFO}) {
//     // Logger.root.level = Level.ALL;
//     // Logger.root.onRecord.listen((record) {
//     //   // ignore: avoid_print
//     //   print('${record.level.name}: ${record.time}: ${record.message}');
//     // });
//     // setLogLevel(logLevel);
//   }
//   static final MovisensFlutter _instance = MovisensFlutter._();
//   static MovisensFlutter get instance => _instance;
// }
