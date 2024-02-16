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
    case unlock = "SCREEN_UNLOCKED"
    case unknown = "UNKNOWN"

    init(fromString string: String) {
        switch string {
        case "SCREEN_ON":
            self = .on
        case "SCREEN_OFF":
            self = .off
        case "SCREEN_UNLOCKED":
            self = .unlock
        default:
            self = .unknown
        }
    }

}

public class ScreenStateDetector: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var lastState: ScreenState = .unknown

    private func handleEvent(screenState: ScreenState) {
        if (screenState == .unknown || eventSink == nil) {
            return
        }

        eventSink!(screenState.rawValue)
    }

    @objc
    private func handleStateChange() {
        if UIApplication.shared.isProtectedDataAvailable {
            let screenState: ScreenState = UIScreen.main.brightness > 0 ? .on : .off

            if(screenState == .on && lastState == .unlock) {
                return
            }

            if screenState != lastState {
                 lastState = screenState
               handleEvent(screenState: screenState)
            }
        }
    }

    @objc
    private func handleScreenLockChanged() {
        if UIApplication.shared.isProtectedDataAvailable {
            if (lastState == .on) {
                lastState = .unlock
                handleEvent(screenState: .unlock)
            }
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events

        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChange), name: UIScreen.brightnessDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenLockChanged), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenLockChanged), name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
}