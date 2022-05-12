package dk.cachet.empatica_e4link;

import android.content.Context;
import android.util.Log;

import com.empatica.empalink.ConnectionNotAllowedException;
import com.empatica.empalink.EmpaDeviceManager;
import com.empatica.empalink.EmpaticaDevice;

import java.util.HashMap;

public class EmpaticaHandler{
    private static final String TAG = "EmpaticaPlugin";
    private final EmpaDeviceManager _handler;
    EmpaStatusEventStreamHandler empaStatusEventStreamHandler;

    EmpaticaHandler(EmpaDataEventStreamHandler empaDataDelegate, EmpaStatusEventStreamHandler empaStatusDelegate, Context context) {
        empaStatusEventStreamHandler = empaStatusDelegate;
        Log.d(TAG, "EmpaticaHandler: ");
        this._handler = new EmpaDeviceManager(context, empaDataDelegate, empaStatusDelegate);
    }

    public void authenticateWithAPIKey(String key) {
        this._handler.authenticateWithAPIKey(key);
    }

    public void authenticateWithConnectUser() {
        this._handler.authenticateWithConnectUser();
    }

    public void startScanning() {
        this._handler.prepareScanning();
        this._handler.startScanning();
        empaStatusEventStreamHandler.discoveredDevices = new HashMap<>();
    }

    public void stopScanning() {
        this._handler.stopScanning();
        empaStatusEventStreamHandler.discoveredDevices = new HashMap<>();
    }

    public void connectDevice(String serialNumber) throws ConnectionNotAllowedException {
        this._handler.stopScanning();
        final EmpaticaDevice device = empaStatusEventStreamHandler.discoveredDevices.get(serialNumber);

        if (device != null) {

            this._handler.connectDevice(device);
        }
    }

}
