package dk.cachet.esense;

import java.util.HashMap;

import io.esense.esenselib.*;
import io.flutter.plugin.common.EventChannel.*;
import io.flutter.plugin.common.PluginRegistry;

public class ESenseEventStreamHandler implements StreamHandler, ESenseEventListener {

    PluginRegistry.Registrar registrar;
    ESenseManagerMethodCallHandler eSenseManagerMethodCallHandler;
    MainThreadEventSink eventSink;

    ESenseEventStreamHandler(PluginRegistry.Registrar registrar, ESenseManagerMethodCallHandler eSenseManagerMethodCallHandler) {
        this.registrar = registrar;
        this.eSenseManagerMethodCallHandler = eSenseManagerMethodCallHandler;
    }

    /* -----------------------------------
            StreamHandler callbacks
     ------------------------------------- */

    @Override
    public void onListen(Object o, EventSink rawEventSink) {
        this.eventSink = new MainThreadEventSink(rawEventSink);
        HashMap map = new HashMap();
        map.put("type", "Listen");
        boolean success = eSenseManagerMethodCallHandler.manager.registerEventListener(this);
        map.put("success", success);
        eventSink.success(map);
    }

    @Override
    public void onCancel(Object o) {
        eventSink.endOfStream();
        this.eventSink = null;
    }


    /* -----------------------------------
       ESenseEventListener callbacks
     ------------------------------------- */


    /**
     * Called when the information on battery voltage has been received
     *
     * @param voltage battery voltage in Volts
     */
    @Override
    public void onBatteryRead(double voltage) {
        if (eventSink != null) {
            HashMap map = new HashMap();
            map.put("type", "BatteryRead");
            map.put("voltage", voltage);
            eventSink.success(map);
        }
    }

    /**
     * Called when the button event has changed
     *
     * @param pressed true if the button is pressed, false if it is released
     */
    @Override
    public void onButtonEventChanged(boolean pressed) {

    }

    /**
     * Called when the information on advertisement and connection interval has been received
     *
     * @param minAdvertisementInterval minimum advertisement interval (unit: milliseconds)
     * @param maxAdvertisementInterval maximum advertisement interval (unit: milliseconds)
     * @param minConnectionInterval    minimum connection interval (unit: milliseconds)
     * @param maxConnectionInterval    maximum connection interval (unit: milliseconds)
     */
    @Override
    public void onAdvertisementAndConnectionIntervalRead(int minAdvertisementInterval, int maxAdvertisementInterval, int minConnectionInterval, int maxConnectionInterval) {

    }

    /**
     * Called when the information on the device name has been received
     *
     * @param deviceName name of the device
     */
    @Override
    public void onDeviceNameRead(String deviceName) {
        if (eventSink != null) {
            HashMap map = new HashMap();
            map.put("type", "DeviceNameRead");
            map.put("name", deviceName);
            eventSink.success(map);
        }
    }

    /**
     * Called when the information on sensor configuration has been received
     *
     * @param config current sensor configuration
     */
    @Override
    public void onSensorConfigRead(ESenseConfig config) {

    }

    /**
     * Called when the information on accelerometer offset has been received
     *
     * @param offsetX x-axis factory offset
     * @param offsetY y-axis factory offset
     * @param offsetZ z-axis factory offset
     */
    @Override
    public void onAccelerometerOffsetRead(int offsetX, int offsetY, int offsetZ) {

    }


}
