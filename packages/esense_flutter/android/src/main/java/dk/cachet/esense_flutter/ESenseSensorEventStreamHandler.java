package dk.cachet.esense_flutter;

import java.util.HashMap;

import io.esense.esenselib.*;
import io.flutter.plugin.common.EventChannel.*;

public class ESenseSensorEventStreamHandler implements StreamHandler, ESenseSensorListener {

    private ESenseManagerMethodCallHandler eSenseManagerMethodCallHandler;
    private MainThreadEventSink eventSink;

    ESenseSensorEventStreamHandler(ESenseManagerMethodCallHandler eSenseManagerMethodCallHandler) {
        this.eSenseManagerMethodCallHandler = eSenseManagerMethodCallHandler;
    }

    @Override
    public void onListen(Object o, EventSink rawEventSink) {
        this.eventSink = new MainThreadEventSink(rawEventSink);
        eSenseManagerMethodCallHandler.manager.registerSensorListener(this,
                eSenseManagerMethodCallHandler.getSamplingRate());
    }

    @Override
    public void onCancel(Object o) {
        eventSink.endOfStream();
        eSenseManagerMethodCallHandler.manager.unregisterSensorListener();
        this.eventSink = null;
    }

    /**
     * Called when there is new sensor data available
     */
    @Override
    public void onSensorChanged(ESenseEvent evt) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "SensorChanged");
            map.put("timestamp", evt.getTimestamp());
            map.put("packetIndex", evt.getPacketIndex());
            map.put("accel.x", evt.getAccel()[0]);
            map.put("accel.y", evt.getAccel()[1]);
            map.put("accel.z", evt.getAccel()[2]);
            map.put("gyro.x", evt.getGyro()[0]);
            map.put("gyro.y", evt.getGyro()[1]);
            map.put("gyro.z", evt.getGyro()[2]);
            eventSink.success(map);
        }
    }
}
