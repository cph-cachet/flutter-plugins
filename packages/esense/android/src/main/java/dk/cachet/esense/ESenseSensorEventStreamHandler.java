package dk.cachet.esense;

import io.esense.esenselib.*;
import io.flutter.plugin.common.EventChannel.*;

public class ESenseSensorEventStreamHandler implements StreamHandler, ESenseSensorListener {
    /**
     * Called when there is new sensor data available
     *
     * @param evt object containing the sensor samples received
     */
    @Override
    public void onSensorChanged(ESenseEvent evt) {

    }

    @Override
    public void onListen(Object o, EventSink eventSink) {

    }

    @Override
    public void onCancel(Object o) {

    }
}
