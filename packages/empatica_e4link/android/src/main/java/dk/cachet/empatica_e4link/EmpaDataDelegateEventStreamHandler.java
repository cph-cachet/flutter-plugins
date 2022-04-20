package dk.cachet.empatica_e4link;

import com.empatica.empalink.delegate.EmpaDataDelegate;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;

public class EmpaDataDelegateEventStreamHandler implements StreamHandler, EmpaDataDelegate {
    MainThreadEventSink eventSink;

    EmpaDataDelegateEventStreamHandler() {
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
    public void didReceiveGSR(float gsr, double timestamp) {
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

}
