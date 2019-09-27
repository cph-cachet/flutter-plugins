/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

package dk.cachet.esense_flutter;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.*;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import io.esense.esenselib.*;

public class ESenseManagerMethodCallHandler implements MethodCallHandler {

    public static final int TIMEOUT = 5 * 1000;

    private boolean connected = false;
    private Registrar registrar;
    private ESenseConnectionEventStreamHandler eSenseConnectionEventStreamHandler;

    private int samplingRate = 10;  // default 10 Hz.
    ESenseManager manager;

    public ESenseManagerMethodCallHandler(
            Registrar registrar,
            ESenseConnectionEventStreamHandler eSenseConnectionEventStreamHandler) {
        this.registrar = registrar;
        this.eSenseConnectionEventStreamHandler = eSenseConnectionEventStreamHandler;
    }

    /**
     * The current sampling rate as specified in the [setSamplingRate] method
     *
     * @return the sampling rate in Hz.
     */
    public int getSamplingRate() {return samplingRate;}

    @Override
    public void onMethodCall(MethodCall call, Result rawResult) {
        Result result = new MainThreadResult(rawResult);
        boolean success;

        switch (call.method) {
            case "connect":
                final String name = call.argument("name");
                manager = new ESenseManager(name, registrar.activity().getApplicationContext(), eSenseConnectionEventStreamHandler);
                connected = manager.connect(TIMEOUT);
                result.success(connected);
                break;
            case "disconnect":
                connected = manager.disconnect();
                result.success(connected);
                break;
            case "isConnected":
                connected = manager.isConnected();
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
            case "setDeviceName":
                String deviceName = call.argument("deviceName");
                success = manager.setDeviceName(deviceName);
                result.success(success);
                break;
            case "getBatteryVoltage":
                success = manager.getBatteryVoltage();
                result.success(success);
                break;
            case "getAccelerometerOffset":
                success = manager.getAccelerometerOffset();
                result.success(success);
                break;
            case "getAdvertisementAndConnectionInterval":
                success = manager.getAdvertisementAndConnectionInterval();
                result.success(success);
                break;
            case "setAdvertisementAndConnectiontInterval":
                final int advMinInterval = call.argument("advMinInterval");
                final int advMaxInterval = call.argument("advMaxInterval");
                final int connMinInterval = call.argument("connMinInterval");
                final int connMaxInterval = call.argument("connMaxInterval");
                success = manager.setAdvertisementAndConnectiontInterval(
                        advMinInterval,
                        advMaxInterval,
                        connMinInterval,
                        connMaxInterval);
                result.success(success);
                break;
            case "getSensorConfig":
                success = manager.getSensorConfig();
                result.success(success);
                break;
            case "setSensorConfig":
                // TODO - implement serialization of ESenseConfig object btw. Java and Dart.
                // ESenseConfig config = call.argument("config");
                // success = manager.setSensorConfig(config);
                // result.success(success);
                result.notImplemented();
                break;
            default:
                result.notImplemented();
        }
    }
}
