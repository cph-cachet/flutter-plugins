import Flutter
import UIKit

import CoreMotion

public class SwiftPedometerPlugin: NSObject, FlutterPlugin {

    // Register Plugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let stepDetectionHandler = StepDetector()
        let stepDetectionChannel = FlutterEventChannel.init(name: "step_detection", binaryMessenger: registrar.messenger())
        stepDetectionChannel.setStreamHandler(stepDetectionHandler)
        // let stepCountHandler = StepCountHandler()
        // let stepCountChannel = FlutterEventChannel.init(name: "step_count", binaryMessenger: registrar.messenger())
        // stepCountChannel.setStreamHandler(instance)
    }
}

class StepDetector: NSObject, FlutterStreamHandler {
    private let pedometer = CMPedometer()
    private var running = false
    private let available = CMPedometer.isStepCountingAvailable()
    private var eventSink: FlutterEventSink?

    private func sendEvent(stepType: Int) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit step count event to Flutter
        eventSink!(stepType)
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        if (available && !running) {
            running = true
            if #available(iOS 13, *) {
                pedometer.startEventUpdates() {
                    pedometerData, error in
                    guard let pedometerData = pedometerData, error == nil else { return }
                    
                    DispatchQueue.main.async {
                        print("From Swift: \(pedometerData.type.rawValue)")
                        self.sendEvent(stepType: pedometerData.type.rawValue)
                    }
                }
            }
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        
        if (running) {
            pedometer.stopUpdates()
            running = false
        }
        return nil
    }
}

// class StepCounter: FlutterStreamHandler {
//     private let pedometer = CMPedometer()
//     private var running = false
//     private let available = CMPedometer.isStepCountingAvailable()
    
//     func onListen() {
//         if (available && !running) {
//             running = true
//             pedometer.startUpdates(from: Date()) {
//                 pedometerData, error in
//                 guard let pedometerData = pedometerData, error == nil else { return }
                
//                 DispatchQueue.main.async {
//                     print(pedometerData)
//                 }
//             }
//         }
//     }
    
//     func onCancel() {
//         if (running) {
//             pedometer.stopUpdates()
//             running = false
//         }
//     }
// }
