/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

package dk.cachet.esense;

import android.Manifest;
import io.flutter.plugin.common.*;
import io.flutter.plugin.common.MethodChannel.*;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** EsensePlugin */
public class EsensePlugin implements MethodCallHandler {

  public static final String ESenseManagerMethodChannelName = "esense.io/esense_manager";
  public static final String ESenseConnectionEventChannelName = "esense.io/esense_connection";
  public static final String ESenseEventEventChannelName = "esense.io/esense_events";
  public static final String ESenseSensorEventChannelName = "esense.io/esense_sensor";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "esense");
    channel.setMethodCallHandler(new EsensePlugin());

    registrar.activity().requestPermissions(new String[]{
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION,
    }, 0);

    final  ESenseConnectionEventStreamHandler eSenseConnectionEventStreamHandler = new ESenseConnectionEventStreamHandler(registrar);
    final ESenseManagerMethodCallHandler eSenseManagerMethodCallHandler = new ESenseManagerMethodCallHandler(registrar,eSenseConnectionEventStreamHandler);

    final MethodChannel eSenseManagerMethodChannel = new MethodChannel(registrar.messenger(), ESenseManagerMethodChannelName);
    eSenseManagerMethodChannel.setMethodCallHandler(eSenseManagerMethodCallHandler);

    final EventChannel eSenseConnectionEventChannel = new EventChannel(registrar.messenger(), ESenseConnectionEventChannelName);
    eSenseConnectionEventChannel.setStreamHandler(eSenseConnectionEventStreamHandler);

    final EventChannel eSenseEventChannel = new EventChannel(registrar.messenger(), ESenseEventEventChannelName);
    eSenseEventChannel.setStreamHandler(new ESenseEventStreamHandler(eSenseManagerMethodCallHandler));

    final EventChannel eSenseSensorEventChannel = new EventChannel(registrar.messenger(), ESenseSensorEventChannelName);
    eSenseSensorEventChannel.setStreamHandler(new ESenseSensorEventStreamHandler(eSenseManagerMethodCallHandler));
  }

  @Override
  public void onMethodCall(MethodCall call, Result rawResult) {
    Result result = new MainThreadResult(rawResult);
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }
}

