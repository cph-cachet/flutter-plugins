package dk.cachet.empatica_e4link;

import com.empatica.empalink.EmpaticaDevice;
import com.empatica.empalink.config.EmpaSensorStatus;
import com.empatica.empalink.config.EmpaSensorType;
import com.empatica.empalink.config.EmpaStatus;
import com.empatica.empalink.delegate.EmpaStatusDelegate;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;

public class EmpaStatusEventStreamHandler implements StreamHandler, EmpaStatusDelegate {
    private MainThreadEventSink statusEventSink;
    public HashMap<String, EmpaticaDevice> discoveredDevices;

    EmpaStatusEventStreamHandler() {
    }

    /*
     * -----------------------------------
     * EmpaticaEventListener callbacks
     * -------------------------------------
     */

    /**
     * Called when the status of the device updates
     *
     * @param status the status that is updated, which is of type EmpaStatus
     */
    @Override
    public void didUpdateStatus(EmpaStatus status) {
        if (statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateStatus");
            map.put("status", status.toString());
            statusEventSink.success(map);
        }
    }

    /**
     * Called when the connection to the device is established
     */
    @Override
    public void didEstablishConnection() {
        if (statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "EstablishConnection");
            statusEventSink.success(map);
        }
    }

    /**
     * Called when the sensor updates its status
     *
     * This method has never been called to my knowledge...
     * 
     * @param status of whether the wristband is on the wrist or not
     * @param type   an enum of the different measurable conditions
     */
    @Override
    public void didUpdateSensorStatus(@EmpaSensorStatus int status, EmpaSensorType type) {
        if (statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateSensorStatus");
            map.put("status", status);
            map.put("empaSensorType", type.toString());
            statusEventSink.success(map);
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
        if (!allowed)
            return;
        if (statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "DiscoverDevice");
            map.put("device", device.serialNumber);
            map.put("deviceLabel", deviceLabel);
            map.put("rssi", rssi);
            discoveredDevices.put(device.serialNumber, device);
            statusEventSink.success(map);
        }
    }

    /**
     * Called if the startScanning() procedure failed
     *
     * @param errorCode the error code of the failed scan
     */
    @Override
    public void didFailedScanning(int errorCode) {
        if (statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "FailedScanning");
            map.put("errorCode", errorCode);
            statusEventSink.success(map);
        }
    }

    /**
     *
     */
    @Override
    public void didRequestEnableBluetooth() {
        if (statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "RequestEnableBluetooth");
            statusEventSink.success(map);
        }
    }

    /**
     * whenever the bluetooth state of the device changed
     */
    @Override
    public void bluetoothStateChanged() {
        if (statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "bluetoothStateChanged");
            statusEventSink.success(map);
        }
    }

    /**
     * This method is here because the StatusDelegate interface implements the
     * method.
     * Therefore build errors will happen without it. It is however expected to be
     * in the DataDelegate
     * in the native C code which is also where it will be called from.
     * This will (probably) never be called from this context. This is an error on
     * the
     * side of Empatica.
     * It has been implemented as the other methods just in case.
     */
    @Override
    public void didUpdateOnWristStatus(@EmpaSensorStatus int status) {
        if (statusEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateOnWristStatus");
            map.put("status", status);
            statusEventSink.success(map);
        }
    }

    @Override
    public void onListen(Object arguments, EventSink events) {
        this.statusEventSink = new MainThreadEventSink(events);
        HashMap<String, Object> map = new HashMap<>();
        map.put("type", "Listen");
        map.put("stream", "status");
        statusEventSink.success(map);
    }

    @Override
    public void onCancel(Object arguments) {
        statusEventSink.endOfStream();
        this.statusEventSink = null;
    }
}
