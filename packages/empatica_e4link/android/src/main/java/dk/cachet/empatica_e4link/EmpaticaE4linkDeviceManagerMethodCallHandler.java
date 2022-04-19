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
import com.empatica.empalink.config.EmpaSensorStatus;
import com.empatica.empalink.config.EmpaSensorType;
import com.empatica.empalink.config.EmpaStatus;
import com.empatica.empalink.delegate.EmpaDataDelegate;
import com.empatica.empalink.delegate.EmpaStatusDelegate;

import java.net.HttpCookie;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.*;

public class EmpaticaE4DeviceManagerMethodCallHandler extends EmpaDeviceManager implements EmpaDataDelegate, EmpaStatusDelegate {
    final MethodChannel channel;
    final private EmpaDeviceManager empaticaManager;
    Map<String, EmpaticaDevice> discoveredDevices = new HashMap<>();

    public EmpaticaE4DeviceManagerMethodCallHandler(Context context, EmpaDataDelegate dataDelegate, EmpaStatusDelegate statusDelegate, MethodChannel channel) {
        super(context, dataDelegate, statusDelegate);

        this.channel = channel;

        this.empaticaManager = new EmpaDeviceManager(context, this, this);
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

    @Override
    public void didReceiveGSR(float gsr, double timestamp) {

    }

    @Override
    public void didReceiveBVP(float bvp, double timestamp) {

    }

    @Override
    public void didReceiveIBI(float ibi, double timestamp) {

    }

    @Override
    public void didReceiveTemperature(float t, double timestamp) {

    }

    @Override
    public void didReceiveAcceleration(int x, int y, int z, double timestamp) {

    }

    @Override
    public void didReceiveBatteryLevel(float level, double timestamp) {

    }

    @Override
    public void didReceiveTag(double timestamp) {

    }

    @Override
    public void didUpdateStatus(EmpaStatus status) {

    }

    @Override
    public void didEstablishConnection() {

    }

    @Override
    public void didUpdateSensorStatus(int status, EmpaSensorType type) {

    }

    @Override
    public void didDiscoverDevice(EmpaticaDevice device, String deviceLabel, int rssi, boolean allowed) {

    }

    @Override
    public void didFailedScanning(int errorCode) {

    }

    @Override
    public void didRequestEnableBluetooth() {

    }

    @Override
    public void bluetoothStateChanged() {

    }

    @Override
    public void didUpdateOnWristStatus(@EmpaSensorStatus int status) {
        channel.invokeMethod("didUpdateSensorStatus", status);
    }
}
