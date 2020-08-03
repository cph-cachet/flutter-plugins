import Flutter
import UIKit

import CoreMotion

public class SwiftPedometerPlugin: NSObject, FlutterPlugin {

    // Register Plugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let stepDetectionHandler = StepDetector()
        let stepDetectionChannel = FlutterEventChannel.init(name: "step_detection", binaryMessenger: registrar.messenger())
        stepDetectionChannel.setStreamHandler(stepDetectionHandler)

        let stepCountHandler = StepCounter()
        let stepCountChannel = FlutterEventChannel.init(name: "step_count", binaryMessenger: registrar.messenger())
        stepCountChannel.setStreamHandler(stepCountHandler)
    }
}

/// StepDetector, handles pedestrian status streaming
public class StepDetector: NSObject, FlutterStreamHandler {
    private let pedometer = CMPedometer()
    private var running = false
    private let available = CMPedometer.isStepCountingAvailable()
    private var eventSink: FlutterEventSink?

    private func handleEvent(status: Int) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit pedestrian status event to Flutter
        eventSink!(status)
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
                        print("From Swift - Pedestrian Status: \(pedometerData.type.rawValue)")
                        self.handleEvent(status: pedometerData.type.rawValue)
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

/// StepCounter, handles step count streaming
public class StepCounter: NSObject, FlutterStreamHandler {
    private let pedometer = CMPedometer()
    private var running = false
    private let available = CMPedometer.isStepCountingAvailable()
    private var eventSink: FlutterEventSink?

    private func handleEvent(count: Int) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit step count event to Flutter
        eventSink!(count)
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink

        let systemUptime = ProcessInfo.processInfo.systemUptime;
        let timeNow = Date().timeIntervalSince1970
        let dateOfLastReboot = Date(timeIntervalSince1970: timeNow - systemUptime)
        if (available && !running) {
            running = true
            if #available(iOS 13, *) {
                pedometer.startUpdates(from: dateOfLastReboot) {
                    pedometerData, error in
                    guard let pedometerData = pedometerData, error == nil else { return }

                    DispatchQueue.main.async {
                        print("From Swift - Step Count: \(pedometerData.numberOfSteps.intValue)")
                        self.handleEvent(count: pedometerData.numberOfSteps.intValue)
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
