/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
package dk.cachet.empatica_e4link;

import android.bluetooth.BluetoothDevice;
import android.content.Context;

import androidx.annotation.NonNull;

import com.empatica.empalink.ConnectionNotAllowedException;
import com.empatica.empalink.EmpaDeviceManager;
import com.empatica.empalink.EmpaticaDevice;
import com.empatica.empalink.delegate.EmpaDataDelegate;
import com.empatica.empalink.delegate.EmpaStatusDelegate;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class EmpaDeviceManagerMethodCallHandler extends EmpaDeviceManager implements MethodCallHandler {
    final MethodChannel channel;
    private EmpaDeviceManager empaticaManager;
    private final EmpaDataDelegateEventStreamHandler dataDelegate = new EmpaDataDelegateEventStreamHandler();
    private final EmpaStatusDelegateEventStreamHandler statusDelegate = new EmpaStatusDelegateEventStreamHandler();
    private Context context;

    Map<String, EmpaticaDevice> discoveredDevices = new HashMap<>();


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result rawResult) {
        Result result = new MainThreadResult(rawResult);

        switch (call.method) {
            case "connectDevice":
                try {
                    empaticaManager = new EmpaDeviceManager(context, dataDelegate, statusDelegate);
                    final EmpaticaDevice device = call.argument("device");
                    connectDevice(device);
                } catch (ConnectionNotAllowedException e) {
                    result.error("ConnectionNotAllowedException", "Connection not allowed.", e);
                }
                break;
            case "startScanning":
                startScanning();
                break;
            case "stopScanning":
                stopScanning();
                break;
            case "setDiscoveredDevices":
                final HashMap<String, EmpaticaDevice> discoveredDevices = call.argument("discoveredDevices");
                setDiscoveredDevices(discoveredDevices);
                break;
            case "getActiveDevice":
                result.success(getActiveDevice());
                break;
            default:
                result.notImplemented();
        }
    }


    public EmpaDeviceManagerMethodCallHandler(Context context, EmpaDataDelegate dataDelegate, EmpaStatusDelegate statusDelegate, MethodChannel channel) {
        super(context, dataDelegate, statusDelegate);

        this.context = context;
        this.channel = channel;

        this.empaticaManager = new EmpaDeviceManager(context, dataDelegate, statusDelegate);
    }


    public void connectDevice(EmpaticaDevice device) throws ConnectionNotAllowedException {
        empaticaManager.connectDevice(device);
    }

    public void stopScanning() {
        empaticaManager.stopScanning();
    }

    private void setDiscoveredDevices(Map<String, EmpaticaDevice> discoveredDevices) {
        this.discoveredDevices = discoveredDevices;
    }

    public void startScanning() {
        empaticaManager.prepareScanning();
        empaticaManager.startScanning();
        setDiscoveredDevices(new HashMap<>());
    }

    public BluetoothDevice getActiveDevice() {
        return empaticaManager.getActiveDevice();
    }

}
