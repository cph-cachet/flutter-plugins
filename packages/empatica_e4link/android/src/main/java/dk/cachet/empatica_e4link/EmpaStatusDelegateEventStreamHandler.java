package dk.cachet.empatica_e4link;

import com.empatica.empalink.EmpaticaDevice;
import com.empatica.empalink.config.EmpaSensorStatus;
import com.empatica.empalink.config.EmpaSensorType;
import com.empatica.empalink.config.EmpaStatus;
import com.empatica.empalink.delegate.EmpaStatusDelegate;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;


public class EmpaStatusDelegateEventStreamHandler implements StreamHandler, EmpaStatusDelegate {
    MainThreadEventSink eventSink;

    EmpaStatusDelegateEventStreamHandler() {
    }


    @Override
    public void onListen(Object o, EventSink events) {
        this.eventSink = new MainThreadEventSink(events);
        eventSink.success("listen");
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink.endOfStream();
        this.eventSink = null;
    }



    @Override
    public void didUpdateStatus(EmpaStatus status) {
        if(eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateStatus");
            map.put("status", status);
            eventSink.success(map);
        }
    }

    @Override
    public void didEstablishConnection() {

    }

    @Override
    public void didUpdateSensorStatus(@EmpaSensorStatus int status, EmpaSensorType type) {
        if(eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateSensorStatus");
            map.put("status", status);
            map.put("empaSensorType", type);
            eventSink.success(map);
        }
    }

    @Override
    public void didDiscoverDevice(EmpaticaDevice device, String deviceLabel, int rssi, boolean allowed) {
        if (!allowed) return;
        if(eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "DiscoverDevice");
            map.put("device", device);
            map.put("deviceLabel", deviceLabel);
            map.put("rssi", rssi);
            eventSink.success(map);
        }
    }

    @Override
    public void didFailedScanning(int errorCode) {
        if(eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "FailedScanning");
            map.put("errorCode", errorCode);
            eventSink.success(map);
        }
    }

    @Override
    public void didRequestEnableBluetooth() {

    }

    @Override
    public void bluetoothStateChanged() {

    }

    @Override
    public void didUpdateOnWristStatus(int status) {
        if(eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateOnWristStatus");
            map.put("status", status);
            eventSink.success(map);
        }
    }
}
