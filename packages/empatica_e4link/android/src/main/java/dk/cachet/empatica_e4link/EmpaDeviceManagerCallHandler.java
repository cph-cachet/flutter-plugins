/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
package dk.cachet.empatica_e4link;

import android.bluetooth.BluetoothDevice;
import android.content.Context;

import com.empatica.empalink.ConnectionNotAllowedException;
import com.empatica.empalink.EmpaDeviceManager;
import com.empatica.empalink.EmpaticaDevice;
import com.empatica.empalink.delegate.EmpaDataDelegate;
import com.empatica.empalink.delegate.EmpaStatusDelegate;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.*;

public class EmpaDeviceManagerCallHandler extends EmpaDeviceManager {
    final MethodChannel channel;
    final private EmpaDeviceManager empaticaManager;
    private EmpaDataDelegateCallHandler dataDelegate = new EmpaDataDelegateCallHandler();
    private EmpaStatusDelegateCallHandler statusDelegate = new EmpaStatusDelegateCallHandler();

    Map<String, EmpaticaDevice> discoveredDevices = new HashMap<>();

    public EmpaDeviceManagerCallHandler(Context context, EmpaDataDelegate dataDelegate, EmpaStatusDelegate statusDelegate, MethodChannel channel) {
        super(context, dataDelegate, statusDelegate);

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

    public void authenticateWithAPIKey(String key) {
        empaticaManager.authenticateWithAPIKey(key);
    }

    public void authenticateWithConnectUser() {
        super.authenticateWithConnectUser();
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
