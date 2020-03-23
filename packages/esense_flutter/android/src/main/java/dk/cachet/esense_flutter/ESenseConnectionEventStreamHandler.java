package dk.cachet.esense_flutter;

import io.esense.esenselib.*;
import io.flutter.plugin.common.*;
import io.flutter.plugin.common.EventChannel.*;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class ESenseConnectionEventStreamHandler implements StreamHandler, ESenseConnectionListener {

    Registrar registrar;
    MainThreadEventSink eventSink;

    ESenseConnectionEventStreamHandler(Registrar registrar) {
        this.registrar = registrar;
    }


    /* -----------------------------------
            StreamHandler callbacks
     ------------------------------------- */

    @Override
    public void onListen(Object o, EventSink rawEventSink) {
        this.eventSink = new MainThreadEventSink(rawEventSink);
        eventSink.success("listen");  // this will result in an "unknown" event in Flutter
    }

    @Override
    public void onCancel(Object o) {
        eventSink.endOfStream();
        this.eventSink = null;
    }

    /* -----------------------------------
       ESenseConnectionListener callbacks
     ------------------------------------- */

    /**
     * Called when the device with the specified name has been found during a scan
     *
     * @param manager device manager
     */
    @Override
    public void onDeviceFound(ESenseManager manager) {
        if (eventSink != null) eventSink.success("device_found");
    }

    /**
     * Called when the device with the specified name has not been found during a scan
     *
     * @param manager device manager
     */
    @Override
    public void onDeviceNotFound(ESenseManager manager) {
        if (eventSink != null) eventSink.success("device_not_found");
    }

    /**
     * Called when the connection has been successfully made
     *
     * @param manager device manager
     */
    @Override
    public void onConnected(ESenseManager manager) {
        if (eventSink != null) eventSink.success("connected");
    }

    /**
     * Called when the device has been disconnected
     *
     * @param manager device manager
     */
    @Override
    public void onDisconnected(ESenseManager manager) {
        if (eventSink != null) eventSink.success("disconnected");
    }
}
