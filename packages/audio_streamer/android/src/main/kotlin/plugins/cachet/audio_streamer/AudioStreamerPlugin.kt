package plugins.cachet.audio_streamer

import android.app.Activity
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.util.*

/** AudioStreamerPlugin */
public class AudioStreamerPlugin : FlutterPlugin, RequestPermissionsResultListener, EventChannel.StreamHandler, ActivityAware {

    /// Constants
    private val eventChannelName = "audio_streamer.eventChannel"
    private val sampleRate = 44100
    private var bufferSize = 6400 * 2; /// Magical number!
    private val maxAmplitude = 32767 // same as 2^15
    private val logTag = "AudioStreamerPlugin"

    /// Variables (i.e. will change value)
    private var eventSink: EventSink? = null
    private var recording = false

    private var currentActivity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.getFlutterEngine().getDartExecutor()
        val eventChannel = EventChannel(messenger, eventChannelName)
        eventChannel.setStreamHandler(AudioStreamerPlugin());
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        currentActivity = null
    }

    /**
     * Called from Flutter, starts the stream.
     */
    override fun onListen(arguments: Any?, events: EventSink?) {
        this.eventSink = events
        recording = true
        streamMicData()
    }

    /**
     * Called from Flutter, which cancels the stream.
     */
    override fun onCancel(arguments: Any?) {
        recording = false
    }

    /**
     * Called by the plugin itself whenever it detects that permissions have not been granted.
     */
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
        val requestAudioPermissionCode = 200
        when (requestCode) {
            requestAudioPermissionCode -> if (grantResults[0] == PackageManager.PERMISSION_GRANTED) return true
        }
        return false
    }

    /**
     * Starts recording and streaming audio data from the mic.
     * Uses a buffer array of size 512. Whenever buffer is full, the content is sent to Flutter.
     *
     *
     * Source:
     * https://www.newventuresoftware.com/blog/record-play-and-visualize-raw-audio-data-in-android
     */
    private fun streamMicData() {
        Thread(Runnable {
            Process.setThreadPriority(Process.THREAD_PRIORITY_AUDIO)
            val audioBuffer = ShortArray(bufferSize / 2)
            val record = AudioRecord(
                    MediaRecorder.AudioSource.DEFAULT,
                    sampleRate,
                    AudioFormat.CHANNEL_IN_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                    bufferSize)
            if (record.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(logTag, "Audio Record can't initialize!")
                return@Runnable
            }
            /** Start recording loop  */
            record.startRecording()
            while (recording) {
                /** Read data into buffer  */
                record.read(audioBuffer, 0, audioBuffer.size)
                Handler(Looper.getMainLooper()).post {
                    /// Convert to list in order to send via EventChannel.
                    val audioBufferList = ArrayList<Double>()
                    for (impulse in audioBuffer) {
                        val normalizedImpulse = impulse.toDouble() / maxAmplitude.toDouble()
                        audioBufferList.add(normalizedImpulse)
                    }
                    eventSink!!.success(audioBufferList)
                }
            }
            record.stop()
            record.release()
        }).start()
    }
}
