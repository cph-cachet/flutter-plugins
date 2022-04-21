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

        @EmpaDeviceManagerMethodNames String methodName = call.method;
        switch (methodName) {
            case "authenticateWithAPIKey":
                empaticaManager = new EmpaDeviceManager(context, dataDelegate, statusDelegate);
                final String key = call.argument("key");
                authenticateWithAPIKey(key);
                result.success(null);
            case "authenticateWithConnectUser":
                empaticaManager = new EmpaDeviceManager(context, dataDelegate, statusDelegate);
                authenticateWithConnectUser();
                result.success(null);
            case "connectDevice":
                final EmpaticaDevice device = call.argument("device");
                try {
                    connectDevice(device);
                    result.success(null);
                } catch (ConnectionNotAllowedException e) {
                    result.error("ConnectionNotAllowedException", "Connection not allowed.", e);
                }
                break;
            case "startScanning":
                startScanning();
                result.success(null);
                break;
            case "stopScanning":
                stopScanning();
                result.success(null);
                break;
            case "setDiscoveredDevices":
                final HashMap<String, EmpaticaDevice> discoveredDevices = call.argument("discoveredDevices");
                setDiscoveredDevices(discoveredDevices);
                result.success(null);
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

    @Override
    public void authenticateWithConnectUser() {
        empaticaManager.authenticateWithConnectUser();
    }

    /**
     * @param key the key to authenticate with
     */
    @Override
    public void authenticateWithAPIKey(String key) {
        empaticaManager.authenticateWithAPIKey(key);
    }

    /**
     * @param device the device to connect to
     * @throws ConnectionNotAllowedException indicates that Connection is not allowed, ie. because of failed API
     */
    public void connectDevice(EmpaticaDevice device) throws ConnectionNotAllowedException {
        empaticaManager.connectDevice(device);
    }

    /**
     * stop the scanning process started by startScanning()
     */
    public void stopScanning() {
        empaticaManager.stopScanning();
    }

    /**
     * @param discoveredDevices the discovered devices by startScanning()
     */
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
