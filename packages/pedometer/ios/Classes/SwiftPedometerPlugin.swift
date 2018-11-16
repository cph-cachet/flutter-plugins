import Flutter
import UIKit

import CoreMotion

public class SwiftPedometerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    var pedometer = CMPedometer()

    // Register Plugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftPedometerPlugin()

        // Set flutter communication channel for emitting step count updates
        let eventChannel = FlutterEventChannel.init(name: "pedometer.eventChannel", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)

    }

    // Handle stream emitting (Swift => Dart)
    private func sendStepCountEvent(stepCount: Int) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit step count event to Flutter
        eventSink!(stepCount)
    }

    // Event Channel: On Stream Listen
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        let now = Date()
        pedometer.startUpdates(from: now) { (pedometerData, error) in
            if let data = pedometerData {

                // Dispatch method to main thread with an async call
                DispatchQueue.main.async {
                    let _stepCount : Int = (data.numberOfSteps as! Int)
                    self.sendStepCountEvent(stepCount: _stepCount)
                }
            }
        }
        return nil
    }

    // Event Channel: On Stream Cancelled
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
}
