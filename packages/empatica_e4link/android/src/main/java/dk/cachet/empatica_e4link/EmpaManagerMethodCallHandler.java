package dk.cachet.empatica_e4link;

import android.content.Context;

import androidx.annotation.NonNull;

import com.empatica.empalink.ConnectionNotAllowedException;
import com.empatica.empalink.EmpaDeviceManager;
import com.empatica.empalink.EmpaticaDevice;
import com.empatica.empalink.config.EmpaStatus;

import java.net.HttpCookie;
import java.net.URI;
import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

class EmpaManagerMethodCallHandler implements MethodCallHandler {
    private final EmpaDeviceManager _handler;
    EmpaStatusEventStreamHandler empaStatusEventStreamHandler;

    /**
     * Creates a new Empatica Device Manager
     *
     * @param empaDataDelegate   An empatica data delegate
     * @param empaStatusDelegate An empatica status delegate
     * @param context            your application context
     */
    EmpaManagerMethodCallHandler(EmpaDataEventStreamHandler empaDataDelegate,
                                 EmpaStatusEventStreamHandler empaStatusDelegate, Context context) {
        empaStatusEventStreamHandler = empaStatusDelegate;
        this._handler = new EmpaDeviceManager(context, empaDataDelegate, empaStatusDelegate);
    }

    /**
     * Authenticates this Device Manager with the Empatica Backend. An Internet
     * connection is required.
     *
     * @param key the api key
     */
    void authenticateWithAPIKey(String key) {
        this._handler.authenticateWithAPIKey(key);
    }

    /**
     * Get the HTTP cookie from this
     */
    String getSessionIdCookie() {
        return this._handler.getSessionIdCookie().toString();
    }

    /**
     * Starts scanning for Empatica devices
     * Throws a DISCOVERING status on the status event sink because Empatica does not
     */
    void startScanning() {
        this._handler.prepareScanning();
        this._handler.startScanning();
        empaStatusEventStreamHandler.discoveredDevices = new HashMap<>();
        if (empaStatusEventStreamHandler.statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateStatus");
            map.put("status", EmpaStatus.DISCOVERING.toString());
            empaStatusEventStreamHandler.statusEventSink.success(map);
        }
    }

    /**
     * Stops scanning for Empatica devices
     */
    void stopScanning() {
        this._handler.stopScanning();
        empaStatusEventStreamHandler.discoveredDevices = new HashMap<>();
    }

    /**
     * Connects to an Empatica device
     *
     * @param serialNumber the serial number of the device to connect to
     * @throws ConnectionNotAllowedException if connection to device is not allowed
     *                                       (e.g. blacklisted device)
     */
    void connectDevice(String serialNumber) throws ConnectionNotAllowedException {
        this._handler.stopScanning();
        final EmpaticaDevice device = empaStatusEventStreamHandler.discoveredDevices.get(serialNumber);

        if (device != null) {

            this._handler.connectDevice(device);
        }
    }

    /**
     * Returns the hardware address of the connected BluetoothDevice.
     * For example, "00:11:22:AA:BB:CC".
     *
     * @return Bluetooth hardware address as string
     */
    String getActiveDevice() {
        return this._handler.getActiveDevice().getAddress();
    }

    /**
     * Sends the EmpaStatus DISCONNECTED on the status stream.
     */
    void notifyDisconnected() {
        this._handler.notifyDisconnected();
    }

    /**
     * Cleans the Android context
     */
    void cleanUp() {
        this._handler.cleanUp();
    }

    /**
     * Cancels the connection. Same as disconnect but also makes sure the EmpaStatus
     * DISCONNECTED is sent on the Status stream.
     */
    void cancelConnection() {
        this._handler.cancelConnection();
    }

    /**
     * Disconnects from the currently active Empatica device
     */
    void disconnect() {
        this._handler.disconnect();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "authenticateWithAPIKey":
                String key = call.argument("key");
                authenticateWithAPIKey(key);
                result.success(null);
                break;
            case "getSessionIdCookie":
                result.success(getSessionIdCookie());
                break;
            case "startScanning":
                startScanning();
                result.success(null);
                break;
            case "stopScanning":
                stopScanning();
                result.success(null);
                break;
            case "connectDevice":
                try {
                    connectDevice(call.argument("serialNumber"));
                    result.success(null);
                } catch (ConnectionNotAllowedException e) {
                    e.printStackTrace();
                    result.error("connectionNotAllowedException", e.getMessage(), e.fillInStackTrace());
                }
                break;
            case "getActiveDevice":
                result.success(getActiveDevice());
                break;
            case "notifyDisconnected":
                notifyDisconnected();
                result.success(null);
                break;
            case "cleanUp":
                cleanUp();
                result.success(null);
                break;
            case "cancelConnection":
                cancelConnection();
                result.success(null);
                break;
            case "disconnect":
                disconnect();
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }
}
