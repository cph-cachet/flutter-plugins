package dk.cachet.empatica_e4link;

import android.content.Context;
import android.util.Log;

import com.empatica.empalink.ConnectionNotAllowedException;
import com.empatica.empalink.EmpaDeviceManager;
import com.empatica.empalink.EmpaticaDevice;
import com.empatica.empalink.config.EmpaSensorStatus;
import com.empatica.empalink.config.EmpaSensorType;
import com.empatica.empalink.config.EmpaStatus;
import com.empatica.empalink.delegate.EmpaDataDelegate;
import com.empatica.empalink.delegate.EmpaStatusDelegate;

import java.util.HashMap;

public class EmpaticaHandler implements EmpaDataDelegate, EmpaStatusDelegate {
    private static final String TAG = "EmpaticaPlugin";
    private final EmpaDeviceManager _handler;

    MainThreadEventSink eventSink;
    private HashMap<String, EmpaticaDevice> discoveredDevices;

    EmpaticaHandler(Context context) {
        this._handler = new EmpaDeviceManager(context, this, this);
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
        this.discoveredDevices = new HashMap<>();
    }

    public void stopScanning() {
        this._handler.stopScanning();
        this.discoveredDevices = new HashMap<>();
    }

    public void connectDevice(String serialNumber) throws ConnectionNotAllowedException {
        this._handler.stopScanning();
        final EmpaticaDevice device = discoveredDevices.get(serialNumber);

        if (device != null) {

            this._handler.connectDevice(device);
        }
    }


    @Override
    public void didReceiveGSR(float gsr, double timestamp) {
        Log.d(TAG, "didReceiveGSR: " + gsr);
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveGSR");
            map.put("gsr", gsr);
            map.put("timestamp", timestamp);
            eventSink.success(map);
        }
    }

    @Override
    public void didReceiveBVP(float bvp, double timestamp) {
        Log.d(TAG, "didReceiveBVP: " + bvp);
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveBVP");
            map.put("bvp", bvp);
            map.put("timestamp", timestamp);
            eventSink.success(map);
        }
    }

    @Override
    public void didReceiveIBI(float ibi, double timestamp) {
        Log.d(TAG, "didReceiveIBI: " + ibi);
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveIBI");
            map.put("ibi", ibi);
            map.put("timestamp", timestamp);
            eventSink.success(map);
        }
    }

    @Override
    public void didReceiveTemperature(float t, double timestamp) {
        Log.d(TAG, "didReceiveTemperature: " + t);
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveTemperature");
            map.put("temperature", t);
            map.put("timestamp", timestamp);
            eventSink.success(map);
        }
    }

    @Override
    public void didReceiveAcceleration(int x, int y, int z, double timestamp) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveAcceleration");
            map.put("x", x);
            map.put("y", y);
            map.put("z", z);
            map.put("timestamp", timestamp);
            eventSink.success(map);
        }
    }

    @Override
    public void didReceiveBatteryLevel(float level, double timestamp) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveBatteryLevel");
            map.put("batteryLevel", level);
            map.put("timestamp", timestamp);
            eventSink.success(map);
        }
    }

    @Override
    public void didReceiveTag(double timestamp) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveTag");
            map.put("timestamp", timestamp);
            eventSink.success(map);
        }
    }


    /* -----------------------------------
        EmpaticaEventListener callbacks
     ------------------------------------- */

    /**
     * Called when the status of the device updates
     *
     * @param status the status that is updated, which is of type EmpaStatus
     */
    @Override
    public void didUpdateStatus(EmpaStatus status) {
        Log.d(TAG, "didUpdateStatus: " + status);
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateStatus");
            map.put("status", status.toString());
            eventSink.success(map);
        }
    }

    /**
     * Called when the connection to the device is established
     */
    @Override
    public void didEstablishConnection() {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "EstablishConnection");
            eventSink.success(map);
        }
    }

    /**
     * Called when the sensor updates its status (wearer takes it off for example)
     *
     * @param status of whether the wristband is on the wrist or not
     * @param type   an enum of the different measurable conditions
     */
    @Override
    public void didUpdateSensorStatus(@EmpaSensorStatus int status, EmpaSensorType type) {
        Log.d(TAG, "didUpdateSensorStatus: " + status);
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateSensorStatus");
            map.put("status", status);
            map.put("empaSensorType", type);
            eventSink.success(map);
        }
    }

    /**
     * Called when the startScanning() finds a new device
     *
     * @param device      the discovered device
     * @param deviceLabel the label of the discovered device
     * @param rssi        the strength of the signal to the discovered device
     * @param allowed     if it is allowed or not
     */
    @Override
    public void didDiscoverDevice(EmpaticaDevice device, String deviceLabel, int rssi, boolean allowed) {
        Log.d(TAG, "didDiscoverDevice: " + device);
        if (!allowed) return;
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "DiscoverDevice");
            map.put("device", device.serialNumber);
            map.put("deviceLabel", deviceLabel);
            map.put("rssi", rssi);
            discoveredDevices.put(device.serialNumber, device);
//            Log.d(TAG, "didDiscoverDevice: " + device + ". eventSink success.");
            eventSink.success(map);
        }
    }

    /**
     * Called if the startScanning() procedure failed
     *
     * @param errorCode the error code of the failed scan
     */
    @Override
    public void didFailedScanning(int errorCode) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "FailedScanning");
            map.put("errorCode", errorCode);
            eventSink.success(map);
        }
    }

    /**
     *
     */
    @Override
    public void didRequestEnableBluetooth() {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "RequestEnableBluetooth");
            eventSink.success(map);
        }
    }

    /**
     * whenever the bluetooth state of the device changed
     */
    @Override
    public void bluetoothStateChanged() {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "bluetoothStateChanged");
            eventSink.success(map);
        }
    }

    /**
     * @param status on wrist status has been updated
     */
    @Override
    public void didUpdateOnWristStatus(@EmpaSensorStatus int status) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateOnWristStatus");
            map.put("status", status);
            eventSink.success(map);
        }
    }
}
