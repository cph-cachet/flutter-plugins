package dk.cachet.empatica_e4link;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.empatica.empalink.ConnectionNotAllowedException;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class EmpaticaFlutterPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler {
    static final String methodChannelName = "empatica.io/empatica_methodChannel";
    static final String eventSinkName =
            "empatica.io/empatica_eventSink";
    EventSink eventSink;
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private final String TAG = "EmpaticaPlugin";
    private EmpaticaHandler _handler;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel = new MethodChannel(binding.getBinaryMessenger(), methodChannelName);
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(binding.getBinaryMessenger(), eventSinkName);
        eventChannel.setStreamHandler(this);

        Context context = binding.getApplicationContext();

        _handler = new EmpaticaHandler(context);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "testTheChannel":
                Log.d(TAG, "onMethodCall: TestTheChannel");
                result.success(null);
                break;
            case "authenticateWithAPIKey":
                Log.d(TAG, "onMethodCall: authenticateWithAPIKey");
                String key = call.argument("key");
                _handler.authenticateWithAPIKey(key);
                result.success(null);
                break;
            case "authenticateWithConnectUser":
                Log.d(TAG, "onMethodCall: authenticateWithConnectUser");
                _handler.authenticateWithConnectUser();
                result.success(null);
                break;
            case "startScanning":
                Log.d(TAG, "onMethodCall: startScanning");
                _handler.startScanning();
                result.success(null);
                break;
            case "stopScanning":
                Log.d(TAG, "onMethodCall: stopScanning");
                _handler.stopScanning();
                result.success(null);
                break;
            case "connectDevice":
                Log.d(TAG, "onMethodCall: connectDevice");
                try {
                    _handler.connectDevice(call.argument("serialNumber"));
                    result.success(null);
                } catch (ConnectionNotAllowedException e) {
                    e.printStackTrace();
                    result.error("connectionNotAllowedException", e.getMessage(), e.fillInStackTrace());
                }
                break;
        }
    }

    @Override
    public void onListen(Object arguments, EventSink events) {
        this.eventSink = new MainThreadEventSink(events);
        _handler.eventSink = this.eventSink;
        HashMap<String, Object> map = new HashMap<>();
        map.put("type", "Listen");
        Log.d(TAG, "onListen: listening");
        eventSink.success(map);
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink.endOfStream();
        this.eventSink = null;
    }
}
