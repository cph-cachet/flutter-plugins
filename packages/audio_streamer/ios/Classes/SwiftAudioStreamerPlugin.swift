import Flutter
import UIKit
import AVFoundation

public class SwiftAudioStreamerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var eventSink: FlutterEventSink?
  var engine = AVAudioEngine()
  var audioData: [Float] = []
  var recording = false

  // Register plugin
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftAudioStreamerPlugin()
    

    // Set flutter communication channel for emitting updates
    let eventChannel = FlutterEventChannel.init(name: "audio_streamer.eventChannel", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
    instance.setupNotifications()
  }

  private func setupNotifications() {
    // Get the default notification center instance.
    NotificationCenter.default.addObserver(self,
                  selector: #selector(handleInterruption(notification:)),
                  name: AVAudioSession.interruptionNotification,
                  object: nil)
  }

  @objc func handleInterruption(notification: Notification) {
    // If no eventSink to emit events to, do nothing (wait)
    if (eventSink == nil) {
        return
    }
      // To be implemented.
    eventSink!(FlutterError(code: "100", message: "Recording was interrupted", details: "Another process interrupted recording."))
  }

    // Handle stream emitting (Swift => Flutter)
    private func emitValues(values: [Float]) {
      // If no eventSink to emit events to, do nothing (wait)
      if (eventSink == nil) {
          return
      }
      // Emit values count event to Flutter
      eventSink!(values)
    }

    // Event Channel: On Stream Listen
    public func onListen(withArguments arguments: Any?,
      eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        startRecording()
        return nil
    }

    // Event Channel: On Stream Cancelled
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        engine.stop()
        return nil
    }

    func startRecording() {
        engine = AVAudioEngine()
      
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: .mixWithOthers)
        try! AVAudioSession.sharedInstance().setActive(true)
      
        let input = engine.inputNode
        let bus = 0

        input.installTap(onBus: bus, bufferSize: 22050, format: input.inputFormat(forBus: bus)) { (buffer, time) -> Void in
            let samples = buffer.floatChannelData?[0]
            // audio callback, samples in samples[0]...samples[buffer.frameLength-1]
            let arr = Array(UnsafeBufferPointer(start: samples, count: Int(buffer.frameLength)))
            self.emitValues(values: arr)
        }

        try! engine.start()
    }

}
