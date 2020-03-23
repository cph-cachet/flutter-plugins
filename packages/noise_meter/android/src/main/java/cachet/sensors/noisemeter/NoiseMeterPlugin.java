package cachet.sensors.noisemeter;

import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.PluginRegistry;

import android.content.pm.PackageManager;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.ArrayList;


/**
 * NoiseMeterPlugin
 */
public class NoiseMeterPlugin implements PluginRegistry.RequestPermissionsResultListener, EventChannel.StreamHandler {
    private static final String EVENT_CHANNEL_NAME = "noise_meter.eventChannel";
    private EventSink eventSink;
    private static int SAMPLE_RATE = 44100;
    static int BUFFER_SIZE = 22050;
    static int MAX_AMPLITUDE = 32767;
    private static String LOG_TAG = "NoiseCalibration";
    boolean recording = false;
    private static Registrar registrar;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        EventChannel eventChannel = new EventChannel(registrar.messenger(), EVENT_CHANNEL_NAME);
        eventChannel.setStreamHandler(new NoiseMeterPlugin());
        NoiseMeterPlugin.registrar = registrar;
    }

    /**
     * The onListen() method is called when a NoiseLevel object creates a stream of NoiseEvents.
     * onListen starts recording and starts the listen method.
     */
    @Override
    @SuppressWarnings("unchecked")
    public void onListen(Object obj, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        recording = true;
        streamMicData();
    }

    /**
     * Starts recording and streaming audio data from the mic.
     * Uses a buffer array of size 512. Whenever buffer is full, the content is sent to Flutter.
     * <p>
     * Source:
     * https://www.newventuresoftware.com/blog/record-play-and-visualize-raw-audio-data-in-android
     */
    private void streamMicData() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_AUDIO);

                final short[] audioBuffer = new short[BUFFER_SIZE / 2];

                AudioRecord record = new AudioRecord(
                        MediaRecorder.AudioSource.DEFAULT,
                        SAMPLE_RATE,
                        AudioFormat.CHANNEL_IN_MONO,
                        AudioFormat.ENCODING_PCM_16BIT,
                        BUFFER_SIZE);

                if (record.getState() != AudioRecord.STATE_INITIALIZED) {
                    Log.e(LOG_TAG, "Audio Record can't initialize!");
                    return;
                }

                /** Start recording loop */
                record.startRecording();
                while (recording) {
                    /** Read data into buffer */
                    record.read(audioBuffer, 0, audioBuffer.length);
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            /// Convert to list in order to send via EventChannel.
                            ArrayList<Double> audioBufferList = new ArrayList<>();
                            for (short impulse : audioBuffer) {
                                double normalizedImpulse = (double) impulse / (double) MAX_AMPLITUDE;
                                audioBufferList.add(normalizedImpulse);
                            }
                            eventSink.success(audioBufferList);
                        }
                    });
                }
                record.stop();
                record.release();
            }
        }).start();

    }

    /**
     * Called from Flutter, which cancels the stream.
     */
    @Override
    public void onCancel(Object o) {
        recording = false;
    }

    /**
     * Called by the plugin itself whenever it detects that permissions have not been granted.
     */
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
}
