package dk.cachet.screenusage;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Build;
import android.util.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;

import static android.content.Context.SENSOR_SERVICE;

/**
 * ScreenUsagePlugin
 */
public class ScreenUsagePlugin implements StreamHandler {

    private Context context;
    private ScreenReceiver mReceiver;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        ScreenUsagePlugin screenUsagePlugin = new ScreenUsagePlugin(registrar);
        final EventChannel eventChannel = new EventChannel(registrar.messenger(), "screenEvents");
        eventChannel.setStreamHandler(screenUsagePlugin);
    }

    private ScreenUsagePlugin(Registrar registrar) {
        context = registrar.activeContext();
    }

    @Override
    public void onListen(Object o, EventSink eventSink) {
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_SCREEN_ON); // Turn on screen
        filter.addAction(Intent.ACTION_SCREEN_OFF); // Turn off Screen
        filter.addAction(Intent.ACTION_USER_PRESENT); // Unlock screen

        mReceiver = new ScreenReceiver(eventSink);
        context.registerReceiver(mReceiver, filter);
    }

    @Override
    public void onCancel(Object o) {

    }
}
