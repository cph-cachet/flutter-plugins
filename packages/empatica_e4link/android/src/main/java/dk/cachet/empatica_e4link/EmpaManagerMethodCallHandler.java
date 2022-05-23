package dk.cachet.empatica_e4link;

import android.content.Context;

import androidx.annotation.NonNull;

import com.empatica.empalink.ConnectionNotAllowedException;
import com.empatica.empalink.EmpaDeviceManager;
import com.empatica.empalink.EmpaticaDevice;

import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class EmpaManagerMethodCallHandler implements MethodCallHandler {
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
    public void authenticateWithAPIKey(String key) {
        this._handler.authenticateWithAPIKey(key);
    }

    /**
     * // TODO: 12/05/2022
     */
    public void authenticateWithConnectUser() {
        this._handler.authenticateWithConnectUser();
    }

    /**
     * Starts scanning for Empatica devices
     */
    public void startScanning() {
        this._handler.prepareScanning();
        this._handler.startScanning();
        empaStatusEventStreamHandler.discoveredDevices = new HashMap<>();
    }

    /**
     * Stops scanning for Empatica devices
     */
    public void stopScanning() {
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
    public void connectDevice(String serialNumber) throws ConnectionNotAllowedException {
        this._handler.stopScanning();
        final EmpaticaDevice device = empaStatusEventStreamHandler.discoveredDevices.get(serialNumber);

        if (device != null) {

            this._handler.connectDevice(device);
        }
    }

    /**
     * Disconnects from the currently active Empatica device
     */
    public void disconnect() {
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
            case "authenticateWithConnectUser":
                authenticateWithConnectUser();
                result.success(null);
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
            case "disconnect":
                disconnect();
                result.success(null);
                break;
        }
    }
}
