import Flutter
import UIKit

public class SwiftEmpaticaE4linkPlugin: NSObject, FlutterPlugin {
    static let ESenseManagerMethodChannelName = "esense.io/esense_manager";
    static let ESenseConnectionEventChannelName = "esense.io/esense_connection";
    static let ESenseEventEventChannelName = "esense.io/esense_events";
    static let ESenseSensorEventChannelName = "esense.io/esense_sensor";
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "empatica_e4link", binaryMessenger: registrar.messenger())
        let instance = SwiftEmpaticaE4linkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
}


class EmpaAPIManagerMethodCallHandler : NSObject, EmpaticaAPI {
    
}

class EmpaDeviceMaangerMethodCallHandler : NSObject, EmpaticaDeviceManager {
    
}

class EmpaStatusEventStreamHandler : NSObject, EmpaticaDelegate, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.sink = nil
        return nil
    }
    
    var sink: FlutterEventSink?
    
    func didUpdate(_ status: BLEStatus) {
        
    }
    
    func didDiscoverDevices(_ devices: [Any]!) {
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "DiscoverDevices"
        map["devices"] = devices
        self.sink!(map)
    }
}

class EmpaDataEventStreamHandler : NSObject, EmpaticaDeviceDelegate {
    
}
