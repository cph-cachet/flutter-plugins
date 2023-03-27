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
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.util.*

/** AudioStreamerPlugin */
class AudioStreamerPlugin : FlutterPlugin, RequestPermissionsResultListener, EventChannel.StreamHandler, ActivityAware {

    // / Constants
    private val eventChannelName = "audio_streamer.eventChannel"

    // / Method channel for returning the sample rate.
    private val methodChannelName = "audio_streamer.methodChannel"
    private var sampleRate = 44100 // standard value to initialize
    private var bufferSize = 6400 * 2; // / Magical number!
    private val maxAmplitude = 32767 // same as 2^15
    private val logTag = "AudioStreamerPlugin"

    // / Variables (i.e. will change value)
    private var eventSink: EventSink? = null
    private var recording = false

    private var currentActivity: Activity? = null

    private lateinit var audioRecord: AudioRecord;

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        val eventChannel = EventChannel(messenger, eventChannelName)
        eventChannel.setStreamHandler(this)
        val methodChannel = MethodChannel(messenger, methodChannelName)
        methodChannel.setMethodCallHandler {
                call, result ->
            if (call.method == "getSampleRate") {
                // Sample rate never changes, so return the given sample rate.
                result.success(audioRecord?.getSampleRate())
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        recording = false
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
     * Called from Flutter, starts the stream and updates the sample rate using the argument.
     */
    override fun onListen(arguments: Any?, events: EventSink?) {
        this.eventSink = events
        recording = true
        sampleRate = (arguments as Map<*, *>)["sampleRate"] as Int
        if (sampleRate < 4000 || sampleRate > 48000) {
            events!!.error("SampleRateError", "A sample rate of " + sampleRate + "Hz is not supported by Android.", null)
            return
        }
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
     * Sets the sample rate as defined by [sampleRate].
     *
     * Source:
     * https://www.newventuresoftware.com/blog/record-play-and-visualize-raw-audio-data-in-android
     */
    private fun streamMicData() {
        Thread(
            Runnable {
                Process.setThreadPriority(Process.THREAD_PRIORITY_AUDIO)
                val audioBuffer = ShortArray(bufferSize / 2)
                audioRecord = AudioRecord(
                    MediaRecorder.AudioSource.DEFAULT,
                    sampleRate,
                    AudioFormat.CHANNEL_IN_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                    bufferSize,
                )
                if (audioRecord.state != AudioRecord.STATE_INITIALIZED) {
                    Log.e(logTag, "Audio Record can't initialize!")
                    return@Runnable
                }
                /** Start recording loop  */
                audioRecord.startRecording()
                while (recording) {
                    /** Read data into buffer  */
                    audioRecord.read(audioBuffer, 0, audioBuffer.size)
                    Handler(Looper.getMainLooper()).post {
                        // / Convert to list in order to send via EventChannel.
                        val audioBufferList = ArrayList<Double>()
                        for (impulse in audioBuffer) {
                            val normalizedImpulse = impulse.toDouble() / maxAmplitude.toDouble()
                            audioBufferList.add(normalizedImpulse)
                        }
                        eventSink!!.success(audioBufferList)
                    }
                }
                audioRecord.stop()
                audioRecord.release()
            },
        ).start()
    }
}
