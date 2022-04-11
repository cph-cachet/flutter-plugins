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

public class EmpaticaE4DeviceManagerMethodCallHandler extends AppCompatActivity
        implements EmpaDataDelegate, EmpaStatusDelegate {
    final MethodChannel channel;
    final private EmpaDeviceManager empaticaManager;
    Map<String, EmpaticaDevice> discoveredDevices = new HashMap<>();

    private int samplingRate = 10; // default 10 Hz.

    public EmpaticaE4DeviceManagerMethodCallHandler(MethodChannel channel,
            Context context) {
        this.channel = channel;
        this._manager = new EmpaDeviceManager(getApplicationContext(), this, this);
    }

    /**
     * The current sampling rate as specified in the [setSamplingRate] method
     *
     * @return the sampling rate in Hz.
     */
    public int getSamplingRate() {
        return samplingRate;
    }

    public Result authenticateWithAPIKey(String apiKey) {
        return result.success(
                this.empaticaManager.authenticateWithAPIKey(apiKey));
    }

    public Result connectDevice(android.bluetooth.BluetoothDevice device) {
        return result.success(
                this.empaticaManager.connectDevice(device)); // rethink. maybe use discoveredDevices
    }

    public Result disconnect() {
        return result.success(
                this.empaticaManager.disconnect());
    }

    public Result getActiveDevice() {
        return result.success(
                this.empaticaManager.getActiveDevice());
    }

    public Result startScanning() {
        return result.success(
                this.empaticaManager.startScanning()); // fill discoveredDevices when scanning
    }

    public Result stopScanning() {
        return result.success(
                this.empaticaManager.stopScanning());
    }
}
