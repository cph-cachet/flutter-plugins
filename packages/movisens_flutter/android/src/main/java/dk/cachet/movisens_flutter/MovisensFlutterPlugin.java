package dk.cachet.movisens_flutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import java.util.HashMap;

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
    private Registrar registrar;
    static String USER_DATA_KEY = "user_data";
    static String USER_DATA_METHOD = "userData";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        // Set up plugin instance
        MovisensFlutterPlugin plugin = new MovisensFlutterPlugin(registrar);

        // Set up method channel
        final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), "movisens.method_channel");
        methodChannel.setMethodCallHandler(plugin);

        // Set up event channel
        final EventChannel eventChannel = new EventChannel(registrar.messenger(), "movisens.event_channel");
        eventChannel.setStreamHandler(plugin);
    }

    public MovisensFlutterPlugin(Registrar registrar) {
        this.registrar = registrar;
//        Log.v("Flutter Plugin", "Constructor");
        /// Set up the intent filter
        MovisensEventReceiver receiver = new MovisensEventReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(MovisensService.MOVISENS_INTENT_NAME);
        registrar.context().registerReceiver(receiver, intentFilter);
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
        if (methodCall.method.equals(USER_DATA_METHOD)) {
            HashMap<String, String> userDataMap = (HashMap<String, String>) methodCall.argument(USER_DATA_KEY);
            UserData userData = new UserData(userDataMap);
//            Log.d("User Data sent from Flutter", userData.toString());

            /// Start MoviSens service
            PermissionManager manager = new PermissionManager(registrar.activity(), userDataMap);
            manager.startMovisensService();
        } else {
            result.notImplemented();
        }
    }

    class MovisensEventReceiver extends BroadcastReceiver {
        final static String TAG = "MovisensEventReceiver";

        @Override
        public void onReceive(Context context, Intent intent) {
//            Log.d(TAG, "MovisensEventReceiver: onReceive()");
            String batteryLevel = intent.getStringExtra(MovisensService.MOVISENS_BATTERY_LEVEL);
            String tapMarker = intent.getStringExtra(MovisensService.MOVISENS_TAP_MARKER);
            String stepCount = intent.getStringExtra(MovisensService.MOVISENS_STEP_COUNT);
            String timeStamp = intent.getStringExtra(MovisensService.MOVISENS_TIMESTAMP);

            String  hr= intent.getStringExtra(MovisensService.MOVISENS_HR);

            String  isHrvValid= intent.getStringExtra(MovisensService.MOVISENS_IS_HRV_VALID);

            String  hrv= intent.getStringExtra(MovisensService.MOVISENS_HRV);



            String met = intent.getStringExtra(MovisensService.MOVISENS_MET);
            String metLevel = intent.getStringExtra(MovisensService.MOVISENS_MET_LEVEL);
            String bodyPosition = intent.getStringExtra(MovisensService.MOVISENS_BODY_POSITION);
            String movementAcceleration = intent.getStringExtra(MovisensService.MOVISENS_MOVEMENT_ACCELERATION);

            String connectionStatus = intent.getStringExtra(MovisensService.MOVISENS_CONNECTION_STATUS);


            HashMap<String, Object> data = new HashMap<>();

           //  data.put(MovisensService.MOVISENS_TIMESTAMP,timeStamp);

            if(hr!=null)
                data.put(MovisensService.MOVISENS_HR,hr);
            if(isHrvValid!=null)
                data.put(MovisensService.MOVISENS_IS_HRV_VALID,isHrvValid);

            if(hrv!=null)
                data.put(MovisensService.MOVISENS_HRV,hrv);

            if (batteryLevel != null)
                data.put(MovisensService.MOVISENS_BATTERY_LEVEL, batteryLevel);
            if (tapMarker != null) data.put(MovisensService.MOVISENS_TAP_MARKER, tapMarker);
            if (stepCount != null) data.put(MovisensService.MOVISENS_STEP_COUNT, stepCount);

            if (met != null) {
//                Log.d("MET", met);
                data.put(MovisensService.MOVISENS_MET, met);
            }

            if (metLevel != null) data.put(MovisensService.MOVISENS_MET_LEVEL, metLevel);

            if (bodyPosition != null) {
//                Log.d("BODY POSITION", bodyPosition);
                data.put(MovisensService.MOVISENS_BODY_POSITION, bodyPosition);
            }

            if (movementAcceleration != null) {
//                Log.d("MOVEMENT ACCELERATION", movementAcceleration);
                data.put(MovisensService.MOVISENS_MOVEMENT_ACCELERATION, movementAcceleration);
            }
            if (connectionStatus != null) {
                Log.d("CONNECTION_STATUS", connectionStatus);
                data.put(MovisensService.MOVISENS_CONNECTION_STATUS, connectionStatus);
            }
            Log.d("ANDROID_DATA", data.toString());

            eventSink.success(data);
        }
    }
}


