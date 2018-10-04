import Flutter
import UIKit
    
public class SwiftScreenUsagePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftScreenUsagePlugin()    
    
    // Set flutter communication channel for emitting step count updates
    let eventChannel = FlutterEventChannel.init(name: "screenEvents", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)

  }

    @objc func applicationDidBecomeActive(notification: NSNotification) {
        if let eventSink = eventSink {
          eventSink("IOS_SCREEN_UNLOCKED")
        }
    }
    
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        if let eventSink = eventSink {
            eventSink("IOS_SCREEN_LOCKED")
        }
    }
    
    // Event Channel: On Stream Listen
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        
        NotificationCenter.default.addObserver(
          self, 
          selector: #selector(SwiftScreenUsagePlugin.applicationDidBecomeActive(notification:)), 
          name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil
        )
        
        
        NotificationCenter.default.addObserver(
          self, 
          selector: #selector(SwiftScreenUsagePlugin.applicationDidEnterBackground(notification:)),
          name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil
        )
        
        return nil
    }

    // Event Channel: On Stream Cancelled
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
}
