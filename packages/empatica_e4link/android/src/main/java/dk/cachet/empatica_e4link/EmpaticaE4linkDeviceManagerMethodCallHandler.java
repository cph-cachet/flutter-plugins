/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
package dk.cachet.empatica_e4link;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.*;

import java.util.Enumeration;
import java.util.Map;

import android.content.Context;
import com.empatica.empalink.*;

public class EmpaticaE4DeviceManagerMethodCallHandler extends AppCompatActivity implements EmpaDataDelegate, EmpaStatusDelegate {
    final MethodChannel channel;
    final private EmpaDeviceManager _manager;
    Map<String, EmpaticaDevice> discoveredDevices = new HashMap<>();


    private int samplingRate = 10; // default 10 Hz.

    public EmpaticaE4DeviceManagerMethodCallHandler(
            Context context) {
        manager = new EmpaDeviceManager(getApplicationContext(), this, this);
    }

    /**
     * The current sampling rate as specified in the [setSamplingRate] method
     *
     * @return the sampling rate in Hz.
     */
    public int getSamplingRate() {
        return samplingRate;
    }

    @Override
    public void onMethodCall(MethodCall call, Result rawResult) {
        Result result = new MainThreadResult(rawResult);
        boolean success;

        switch (call.method) {
            case "authenticateWithAPIKey":
                final String key = call.argument("key");
                success = manager.authenticateWithAPIKey(key);
                result.success(success);
                break;
            case "connectDevice":
                android.bluetooth.BluetoothDevice device = call.argument("device");
                success = manager.connectDevice(device);
                result.success(success);
                break;
            case "disconnect":
                success = manager.disconnect();
                result.success(success);
                break;
            case "getActiveDevice":
                success = manager.getActiveDevice();
                result.success(success);
                break;
            case "startScanning":
                success = manager.startScanning();
                result.success(success);
                break;
            case "stopScanning":
                success = manager.stopScanning();
                result.success(success);
                break;
            default:
                result.notImplemented();
        }
    }
}
