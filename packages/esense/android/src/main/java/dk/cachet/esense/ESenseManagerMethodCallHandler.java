/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

package dk.cachet.esense;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.*;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import io.esense.esenselib.*;

public class ESenseManagerMethodCallHandler implements MethodCallHandler {

    public static final int timeOut = 5 * 1000;

    boolean connected = false;
    int samplingRate = 10;  // default 10 Hz.
    ESenseManager manager;
    Registrar registrar;
    ESenseConnectionEventStreamHandler eSenseConnectionEventStreamHandler;


    public ESenseManagerMethodCallHandler(
            Registrar registrar,
            ESenseConnectionEventStreamHandler eSenseConnectionEventStreamHandler) {
        this.registrar = registrar;
        this.eSenseConnectionEventStreamHandler = eSenseConnectionEventStreamHandler;
    }

    @Override
    public void onMethodCall(MethodCall call, Result rawResult) {
        Result result = new MainThreadResult(rawResult);
        boolean success;

        switch (call.method) {
            case "connect":
                final String name = call.argument("name");
                manager = new ESenseManager(name, registrar.activity().getApplicationContext(), eSenseConnectionEventStreamHandler);
                connected = manager.connect(timeOut);
                result.success(connected);
                break;
            case "disconnect":
                connected = manager.disconnect();
                result.success(connected);
                break;
            case "setSamplingRate":
                samplingRate = call.argument("rate");
                result.success(true);
                break;
            case "getDeviceName":
                success = manager.getDeviceName();
                result.success(success);
                break;
            case "getBatteryVoltage":
                success = manager.getBatteryVoltage();
                result.success(success);
                break;
            default:
                result.notImplemented();
        }
    }
}
