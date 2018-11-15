package cachet.plugins.noise_level;


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


    /**
     * The onListen() method is called when a NoiseLevel object creates a stream of NoiseEvents.
     * onListen starts recording and starts the listen method.
     */
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
        this.eventSink = null;
        stopRecorder();
    }

    /**
     * Called by the plugin itself whenever it detects that permissions have not been granted.
     * */
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

    /**
     * Called by onListen().
     * */
    private void startRecorder() {
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
        } catch (Exception e) {
            Log.e(TAG, "startRecorder(), MediaRecorder exception: ", e);
        }
    }

    /**
     * Checks if permission to access microphone and storage was granted.
     */
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

    /**
     * Listens to the [MediaRecorder] object with a given frequency and creates a callback
     * to the [NoiseLevel] object in Flutter which created this Plugin object.
     * */
    private void listen() {
        Log.d(TAG, "listen()");

        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                while (isRecording && eventSink != null) {
                    try {
                        int volume = model.getMediaRecorder().getMaxAmplitude();  //Get the sound pressure value
                        NoiseLevel noiseLevel = new NoiseLevel(volume);
                        eventSink.success(noiseLevel.getDecibel());
                        Thread.sleep(frequency);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
        thread.start();
    }

    /**
     * Called by onCancel.
     * */
    private void stopRecorder() {
        isRecording = false;
        recordHandler.removeCallbacks(this.model.getRecorderTicker());
        if (this.model.getMediaRecorder() == null) {
            return;
        }
        this.model.getMediaRecorder().stop();
        this.model.getMediaRecorder().release();
        this.model.setMediaRecorder(null);
        flushAudioFile();
    }

    /**
     * Deletes the audio file used for recording.
     */
    private void flushAudioFile() {
        File file = new File(AudioModel.DEFAULT_FILE_LOCATION);
        if (file.exists()) {
            file.delete();
        }
    }
}


