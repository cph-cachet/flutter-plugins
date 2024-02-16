import Flutter
import UIKit

public class SwiftScreenStatePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let screenStateDetector = ScreenStateDetector()
    let channel = FlutterEventChannel.init(name: "screenStateEvents", binaryMessenger: registrar.messenger())
    channel.setStreamHandler(screenStateDetector)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}

// Convert from string to enum
enum ScreenState: String {
    case on = "SCREEN_ON"
    case off = "SCREEN_OFF"
    case unlock = "UNLOCKED"
    case lock = "LOCKED"
    case unknown = "UNKNOWN"

    init(fromString string: String) {
        switch string {
        case "SCREEN_ON":
            self = .on
        case "SCREEN_OFF":
            self = .off
        case "UNLOCKED":
            self = .unlock
        case "LOCKED":
            self = .lock
        default:
            self = .unknown
        }
    }

}

public class ScreenStateDetector: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var lastState: ScreenState?
    private var timer: Timer?

    private func handleEvent(screenState: ScreenState) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit step count event to Flutter
        eventSink!(screenState.rawValue)
    }

    @objc
    private func handleScreenStateChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            var screenState: ScreenState

            if UIApplication.shared.isProtectedDataAvailable {
                if strongSelf.lastState == .lock {
                    screenState = .unlock
                } else {
                    if UIScreen.main.brightness == 0.0 {
                        screenState = .off
                    } else {
                        screenState = .on
                    }
                }
            } else {
                screenState = .lock
            }

            if screenState != strongSelf.lastState {
                strongSelf.lastState = screenState
                strongSelf.handleEvent(screenState: screenState)
            }
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        self.lastState = .init(fromString: arguments as? String ?? "")

        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(handleScreenStateChanged), userInfo: nil, repeats: true)
        }

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        timer?.invalidate()
        timer = nil
        return nil
    }
}