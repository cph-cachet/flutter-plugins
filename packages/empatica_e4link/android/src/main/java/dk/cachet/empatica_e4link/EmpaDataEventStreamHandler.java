package dk.cachet.empatica_e4link;

import com.empatica.empalink.config.EmpaSensorStatus;
import com.empatica.empalink.delegate.EmpaDataDelegate;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;

public class EmpaDataEventStreamHandler implements StreamHandler, EmpaDataDelegate {
    private MainThreadEventSink dataEventSink;

    EmpaDataEventStreamHandler() {
    }

    /**
     * This method is invoked when a new GSR value is available
     *
     * @param gsr       Galvanic Skin Response
     * @param timestamp the timestamp of the occurrence of the event in UNIX time
     */
    @Override
    public void didReceiveGSR(float gsr, double timestamp) {
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveGSR");
            map.put("gsr", gsr);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    /**
     * This method is invoked when a new BVP value is available
     *
     * @param bvp       Blood Volume Pulse
     * @param timestamp the timestamp of the occurrence of the event in UNIX time
     */
    @Override
    public void didReceiveBVP(float bvp, double timestamp) {
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveBVP");
            map.put("bvp", bvp);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    /**
     * This method is invoked when a new interbeat interval (IBI) value is
     * available. You can compute the heart rate as (60 / ibi).
     *
     * @param ibi       Interbeat Interval
     * @param timestamp the timestamp of the occurrence of the event in UNIX time
     */
    @Override
    public void didReceiveIBI(float ibi, double timestamp) {
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveIBI");
            map.put("ibi", ibi);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    /**
     * This method is invoked when a new temperature value is available
     *
     * @param t         temperature
     * @param timestamp the timestamp of the occurrence of the event in UNIX time
     */
    @Override
    public void didReceiveTemperature(float t, double timestamp) {
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveTemperature");
            map.put("temperature", t);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    /**
     * This method is invoked when a new acceleration value is available
     *
     * @param x         component of the acceleration
     * @param y         component of the acceleration
     * @param z         component of the acceleration
     * @param timestamp the timestamp of the occurrence of the event in UNIX time
     */
    @Override
    public void didReceiveAcceleration(int x, int y, int z, double timestamp) {
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

    /**
     * This method is invoked when a new battery level value is available
     *
     * @param level     battery level in decimal value. 1 = 100%
     * @param timestamp the timestamp of the occurrence of the event in UNIX time
     */
    @Override
    public void didReceiveBatteryLevel(float level, double timestamp) {
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveBatteryLevel");
            map.put("batteryLevel", level);
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    /**
     * This method is invoked when the button on the watch is pressed.
     *
     * @param timestamp the timestamp of the occurrence of the event in UNIX time
     */
    @Override
    public void didReceiveTag(double timestamp) {
        if (dataEventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("type", "ReceiveTag");
            map.put("timestamp", timestamp);
            dataEventSink.success(map);
        }
    }

    /**
     * This method will be called whenever the wristband is taken off and on.
     *
     * The intellisense is not correct, it is supposed to be here.
     *
     * @param status on wrist status has been updated.
     */
    public void didUpdateOnWristStatus(@EmpaSensorStatus int status) {
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
        dataEventSink.success(map);
    }

    @Override
    public void onCancel(Object arguments) {
        dataEventSink.endOfStream();
        this.dataEventSink = null;
    }
}
