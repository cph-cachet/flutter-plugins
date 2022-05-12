package dk.cachet.empatica_e4link;

import com.empatica.empalink.config.EmpaSensorStatus;
import com.empatica.empalink.delegate.EmpaDataDelegate;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;

public class EmpaDataEventStreamHandler implements StreamHandler, EmpaDataDelegate {
    private MainThreadEventSink dataEventSink;
    private static final String TAG = "cachet.empatica.io/dataEventStream";

    EmpaDataEventStreamHandler() {
    }


    @Override
    public void didReceiveGSR(float gsr, double timestamp) {
//        Log.d(TAG, "didReceiveGSR: " + gsr);
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveGSR");
            map.put("gsr", gsr);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    @Override
    public void didReceiveBVP(float bvp, double timestamp) {
//        Log.d(TAG, "didReceiveBVP: " + bvp);
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveBVP");
            map.put("bvp", bvp);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    @Override
    public void didReceiveIBI(float ibi, double timestamp) {
//        Log.d(TAG, "didReceiveIBI: " + ibi);
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveIBI");
            map.put("ibi", ibi);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    @Override
    public void didReceiveTemperature(float t, double timestamp) {
//        Log.d(TAG, "didReceiveTemperature: " + t);
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveTemperature");
            map.put("temperature", t);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    @Override
    public void didReceiveAcceleration(int x, int y, int z, double timestamp) {
//        Log.d(TAG, "didReceiveAcceleration: " + x + y + z);
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveAcceleration");
            map.put("x", x);
            map.put("y", y);
            map.put("z", z);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    @Override
    public void didReceiveBatteryLevel(float level, double timestamp) {
//        Log.d(TAG, "didReceiveBatteryLevel: " + level);
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveBatteryLevel");
            map.put("batteryLevel", level);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    @Override
    public void didReceiveTag(double timestamp) {
//        Log.d(TAG, "didReceiveTag: " + timestamp);
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveTag");
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    /**
     * @param status on wrist status has been updated
     */
    public void didUpdateOnWristStatus(@EmpaSensorStatus int status) {
//        Log.d(TAG, "didUpdateOnWristStatus: " + status);
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "UpdateOnWristStatus");
            map.put("status", status);
            dataEventSink.success(map);
        }
    }


    @Override
    public void onListen(Object arguments, EventSink events) {
        this.dataEventSink = new MainThreadEventSink(events);
        HashMap<String, Object> map = new HashMap<>();
        map.put("type", "Listen");
        map.put("stream", "data");
//        Log.d(TAG, "onListen: listening");
        dataEventSink.success(map);
    }

    @Override
    public void onCancel(Object arguments) {
        dataEventSink.endOfStream();
        this.dataEventSink = null;
    }
}
