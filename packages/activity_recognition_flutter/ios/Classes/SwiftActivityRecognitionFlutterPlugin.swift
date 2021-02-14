import Flutter
import UIKit
import CoreMotion


public class SwiftActivityRecognitionFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  var activityManager: CMMotionActivityManager?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "activity_recognition_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftActivityRecognitionFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
  }

  public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
      /// Init the activity recognition manager
    activityManager = CMMotionActivityManager()

    log(message: "Starting activity tracking...")

    activityManager?.startActivityUpdates(to: OperationQueue.init()) { (activity) in
        if let a = activity {
            
            let type = self.extractActivityType(a: a)
            let confidence = self.extractActivityConfidence(a: a)
            let data = "\(type),\(confidence)"

            /// Send event to flutter
            eventSink(data)
        }
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }

  func log(message: String) {
    NSLog("SwiftActivityRecognitionFlutterPlugin: \(message)");
  }

  func extractActivityType(a: CMMotionActivity) -> String {
    var type = "UNKNOWN"
    switch true {
    case a.stationary:
        type = "STILL"
    case a.walking:
        type = "WALKING"
    case a.running:
        type = "RUNNING"
    case a.automotive:
        type = "IN_VEHICLE"
    case a.cycling:
        type = "ON_BICYCLE"
    default:
        type = "UNKNOWN"
    }
    return type
  }

  func extractActivityConfidence(a: CMMotionActivity) -> Int {
    var conf = -1
    
    switch a.confidence {
    case CMMotionActivityConfidence.low:
        conf = 10
    case CMMotionActivityConfidence.medium:
        conf = 50
    case CMMotionActivityConfidence.high:
        conf = 100
    default:
        conf = -1
    }
    return conf
  }

}
