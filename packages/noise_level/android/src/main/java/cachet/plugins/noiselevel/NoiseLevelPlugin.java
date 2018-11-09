package cachet.plugins.noiselevel;


import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.PluginRegistry;

import android.Manifest;
import android.content.pm.PackageManager;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Handler;
import android.util.Log;

import java.io.File;
import java.util.HashMap;


/**
 * NoiseLevelPlugin
 */
public class NoiseLevelPlugin implements PluginRegistry.RequestPermissionsResultListener, EventChannel.StreamHandler {
    final static String TAG = "NoiseLevelPlugin";
    private static Registrar reg;
    final private AudioModel model = new AudioModel();
    final private Handler recordHandler = new Handler();
    private static EventChannel eventChannel;
    private boolean isRecording = false;
    private EventSink eventSink;
    private int frequency;

    private static final String EVENT_CHANNEL_NAME = "noiseLevel.eventChannel";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        Log.d(TAG, "registerWith()");
        eventChannel = new EventChannel(registrar.messenger(), EVENT_CHANNEL_NAME);
        eventChannel.setStreamHandler(new NoiseLevelPlugin());
        reg = registrar;
    }

    @Override
    @SuppressWarnings("unchecked")
    public void onListen(Object obj, EventChannel.EventSink eventSink) {
        try {
            HashMap<String, String> args = (HashMap<String, String>) obj;
            frequency = Integer.parseInt(args.get("frequency"));
        } catch (Exception e) {
            Log.e(TAG, "onListen(), Type-cast exception: ", e);
        }

        this.eventSink = eventSink;
        startRecorder();
        listen();
    }

    @Override
    public void onCancel(Object o) {
//        Log.d(TAG, "onCancel()");
        this.eventSink = null;
        stopRecorder();
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

    private void startRecorder() {
//        Log.d(TAG, "startRecorder()");
        if (!permissionGranted()) return;

        if (this.model.getMediaRecorder() == null) {
            this.model.setMediaRecorder(new MediaRecorder());
            this.model.getMediaRecorder().setAudioSource(MediaRecorder.AudioSource.MIC);
            this.model.getMediaRecorder().setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            this.model.getMediaRecorder().setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT);
            this.model.getMediaRecorder().setOutputFile(AudioModel.DEFAULT_FILE_LOCATION);
        }

        try {
            this.model.getMediaRecorder().prepare();
            this.model.getMediaRecorder().start();
            isRecording = true;
//            Log.d(TAG, "startRecorder(): Started recording. isRecording? " + isRecording);

        } catch (Exception e) {
            Log.e(TAG, "startRecorder(), MediaRecorder exception: ", e);
        }
    }

    private boolean permissionGranted() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (reg.activity().checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED
                    || reg.activity().checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                    ) {
                reg.activity().requestPermissions(new String[]{
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE,
                }, 0);
                return false;
            }
        }
        return true;
    }

    private void listen() {
        Log.d(TAG, "listen()");

        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
//                Log.d(TAG, "isRecording? " + isRecording);
//                Log.d(TAG, "eventSink?" + (eventSink != null));
                while (isRecording && eventSink != null) {
//                    Log.d(TAG, "Listening...");
                    try {
                        int volume = model.getMediaRecorder().getMaxAmplitude();  //Get the sound pressure value
                        if (volume > 0) {
                            float db = 20 * (float) (Math.log10(volume));
                            eventSink.success(db);
//                            Log.d(TAG, "signal:" + volume + ", dB val: " + db);
                        }
                        Thread.sleep(frequency);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
        thread.start();
    }

    private void stopRecorder() {
        isRecording = false;
        recordHandler.removeCallbacks(this.model.getRecorderTicker());
        if (this.model.getMediaRecorder() == null) {
//            Log.d(TAG, "mediaRecorder is null");
            return;
        }
        this.model.getMediaRecorder().stop();
        this.model.getMediaRecorder().release();
        this.model.setMediaRecorder(null);
        flushAudioFile();
    }

    private void flushAudioFile() {
        File file = new File(AudioModel.DEFAULT_FILE_LOCATION);
        if (file.exists()) {
//            if (file.delete()) {
//                Log.d(TAG, "file Deleted");
//            } else {
//                Log.d(TAG, "file not Deleted");
//            }
        }
    }
}


