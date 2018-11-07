package com.dooboolab.fluttersound;

import android.Manifest;
import android.content.pm.PackageManager;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Handler;
import android.os.SystemClock;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterSoundPlugin
 */
public class FlutterSoundPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener, AudioInterface, EventChannel.StreamHandler {
    final static String TAG = "FlutterSoundPlugin";
    private static final String ERR_RECORDER_IS_NULL = "ERR_RECORDER_IS_NULL";
    private static Registrar reg;
    final private AudioModel model = new AudioModel();
    final private Handler recordHandler = new Handler();
    private static MethodChannel methodChannel;
    private static EventChannel eventChannel;
    private boolean isRecording = false;

    private static final String EVENT_CHANNEL_NAME = "noise.eventChannel";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        eventChannel = new EventChannel(registrar.messenger(), EVENT_CHANNEL_NAME);
        eventChannel.setStreamHandler(new FlutterSoundPlugin());

        methodChannel = new MethodChannel(registrar.messenger(), "flutter_sound");
        methodChannel.setMethodCallHandler(new FlutterSoundPlugin());
        reg = registrar;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        String path = call.argument("path");
        switch (call.method) {
            case "startRecorder":
                this.startRecorder(path, result);
                break;
            case "stopRecorder":
                this.stopRecorder(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        final int REQUEST_RECORD_AUDIO_PERMISSION = 200;
        switch (requestCode) {
            case REQUEST_RECORD_AUDIO_PERMISSION:
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED)
                    return true;
                break;
        }
        return false;
    }

    @Override
    public void startRecorder(String path, final Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (
                    reg.activity().checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED
                            || reg.activity().checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                    ) {
                reg.activity().requestPermissions(new String[]{
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE,
                }, 0);
                result.error(TAG, "NO PERMISSION GRANTED", Manifest.permission.RECORD_AUDIO + " or " + Manifest.permission.WRITE_EXTERNAL_STORAGE);
                return;
            }
        }

        Log.d(TAG, "startRecorder");

        if (path == null) {
            path = AudioModel.DEFAULT_FILE_LOCATION;
        }

        if (this.model.getMediaRecorder() == null) {
            this.model.setMediaRecorder(new MediaRecorder());
            this.model.getMediaRecorder().setAudioSource(MediaRecorder.AudioSource.MIC);
            this.model.getMediaRecorder().setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            this.model.getMediaRecorder().setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT);
            this.model.getMediaRecorder().setOutputFile(path);
        }

        try {
            this.model.getMediaRecorder().prepare();
            this.model.getMediaRecorder().start();
            isRecording = true;
            this.listen();

            final long systemTime = SystemClock.elapsedRealtime();
            this.model.setRecorderTicker(new Runnable() {
                @Override
                public void run() {

                    long time = SystemClock.elapsedRealtime() - systemTime;
                    try {
                        JSONObject json = new JSONObject();
                        json.put("current_position", String.valueOf(time));
                        methodChannel.invokeMethod("updateRecorderProgress", json.toString());
                        recordHandler.postDelayed(model.getRecorderTicker(), model.subsDurationMillis);
                    } catch (JSONException je) {
                        Log.d(TAG, "Json Exception: " + je.toString());
                    }
                }
            });
            this.model.getRecorderTicker().run();
            result.success(path);
        } catch (Exception e) {
            Log.e(TAG, "Exception: ", e);
        }


    }

    void listen() {
        Log.d(TAG, "Is recording? " + isRecording);
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                while (isRecording) {
                    try {
                        int volume = model.getMediaRecorder().getMaxAmplitude();  //Get the sound pressure value
                        float db = 20 * (float) (Math.log10(volume));
                        Log.d(TAG, "signal:" + volume + ", dB val: " + db);
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
        thread.start();
    }

    @Override
    public void stopRecorder(final Result result) {
        isRecording = false;
        recordHandler.removeCallbacks(this.model.getRecorderTicker());
        if (this.model.getMediaRecorder() == null) {
            Log.d(TAG, "mediaRecorder is null");
            result.error(ERR_RECORDER_IS_NULL, ERR_RECORDER_IS_NULL, ERR_RECORDER_IS_NULL);
            return;
        }
        this.model.getMediaRecorder().stop();
        this.model.getMediaRecorder().release();
        this.model.setMediaRecorder(null);
        result.success("recorder stopped.");
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {

    }

    @Override
    public void onCancel(Object o) {

    }
}
