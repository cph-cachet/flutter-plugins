package com.example.movisensflutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import de.kn.uni.smartact.movisenslibrary.bluetooth.MovisensService;
import de.kn.uni.smartact.movisenslibrary.model.UserData;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * MovisensFlutterPlugin
 */
public class MovisensFlutterPlugin implements EventChannel.StreamHandler, MethodChannel.MethodCallHandler {

    private EventChannel.EventSink eventSink;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        // Set up plugin instance
        MovisensFlutterPlugin plugin = new MovisensFlutterPlugin(registrar.activeContext());

        // Set up method channel
        final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), "movisens.method_channel");
        methodChannel.setMethodCallHandler(plugin);

        // Set up event channel
        final EventChannel eventChannel = new EventChannel(registrar.messenger(), "movisens.event_channel");
        eventChannel.setStreamHandler(plugin);
    }

    public MovisensFlutterPlugin(Context context) {
        Log.v("Flutter Plugin", "Constructor");
        /// Set up the intent filter
        MovisensEventReceiver receiver = new MovisensEventReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(MovisensService.MOVISENS_INTENT_NAME);
        context.registerReceiver(receiver, intentFilter);

        /// Start MoviSens service
        Intent intent = new Intent(context, NewActivity.class);
        context.startActivity(intent);
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        this.eventSink = null;

    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        Log.v("USERADATA", "Hello my dude");
        if (methodCall.method.equals("userData")) {
            HashMap<String, String> user = (HashMap<String, String>) methodCall.argument("user_data");
//            UserData data = new UserData(user);
//            Log.d("USERADATA", data.toString());
            String s = user.toString();
            result.success(s);
        }
        else {
            result.notImplemented();
        }
    }

    class MovisensEventReceiver extends BroadcastReceiver {
        final static String TAG = "MovisensEventReceiver";

        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "MovisensEventReceiver: onReceive()");
            String batteryLevel = intent.getStringExtra(MovisensService.MOVISENS_BATTERY_LEVEL);
            String tapMarker = intent.getStringExtra(MovisensService.MOVISENS_TAP_MARKER);
            String stepCount = intent.getStringExtra(MovisensService.MOVISENS_STEP_COUNT);
            HashMap<String, String> data = new HashMap<>();

            if (batteryLevel != null) data.put("batteryLevel", batteryLevel);
            if (tapMarker != null) data.put("tapMarker", tapMarker);
            if (stepCount != null) data.put("stepCount", stepCount);

            eventSink.success(data);
        }
    }
}


