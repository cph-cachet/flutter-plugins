import Flutter
import UIKit
import CoreMotion


public class SwiftActivityRecognitionFlutterPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let handler = ActivityStreamHandler() 
    let channel = FlutterEventChannel(name: "activity_recognition_flutter", binaryMessenger: registrar.messenger())
    channel.setStreamHandler(handler)
  }
}
public class ActivityStreamHandler: NSObject, FlutterStreamHandler {

  private let activityManager = CMMotionActivityManager()

  public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
    activityManager.startActivityUpdates(to: OperationQueue.init()) { (activity) in
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
    activityManager.stopActivityUpdates()
    return nil
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
