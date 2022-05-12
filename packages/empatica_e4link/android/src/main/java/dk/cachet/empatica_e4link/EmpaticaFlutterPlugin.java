package dk.cachet.empatica_e4link;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.empatica.empalink.ConnectionNotAllowedException;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class EmpaticaFlutterPlugin implements FlutterPlugin, MethodCallHandler {
    static final String methodChannelName = "empatica.io/empatica_methodChannel";
    static final String dataEventSinkName =
            "empatica.io/empatica_dataEventSink";
    static final String statusEventSinkName =
            "empatica.io/empatica_statusEventSink";
    private MethodChannel methodChannel;
    EventChannel statusEventChannel;
    EventChannel dataEventChannel;
    private final String TAG = "EmpaticaPlugin";
    private EmpaticaHandler _handler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onAttachedToEngine: ");
        final EmpaStatusEventStreamHandler empaStatusEventStreamHandler = new EmpaStatusEventStreamHandler();
        final EmpaDataEventStreamHandler empaDataEventStreamHandler = new EmpaDataEventStreamHandler();


        methodChannel = new MethodChannel(binding.getBinaryMessenger(), methodChannelName);
        methodChannel.setMethodCallHandler(this);

        statusEventChannel = new EventChannel(binding.getBinaryMessenger(), statusEventSinkName);
        statusEventChannel.setStreamHandler(empaStatusEventStreamHandler);

        Context context = binding.getApplicationContext();

        _handler = new EmpaticaHandler(empaDataEventStreamHandler, empaStatusEventStreamHandler, context);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        dataEventChannel.setStreamHandler(null);
        statusEventChannel.setStreamHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
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
}
