import Flutter
import UIKit
import ESense

public class SwiftEsenseFlutterPlugin: NSObject, FlutterPlugin {
    static let ESenseManagerMethodChannelName = "esense.io/esense_manager";
    static let ESenseConnectionEventChannelName = "esense.io/esense_connection";
    static let ESenseEventEventChannelName = "esense.io/esense_events";
    static let ESenseSensorEventChannelName = "esense.io/esense_sensor";
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        // the following is the auto-generated code when creating the plugin -- not used
        let channel = FlutterMethodChannel(name: "esense_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftEsenseFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // eSense implementation below
        
        let eSenseConnectionEventStreamHandler:ESenseConnectionEventStreamHandler = ESenseConnectionEventStreamHandler()

        // ESenseManger Method Channel
        let  eSenseManagerMethodChannel = FlutterMethodChannel(name: ESenseManagerMethodChannelName, binaryMessenger: registrar.messenger())
        let  eSenseManagerMethodCallHandler =  ESenseManagerMethodCallHandler(eSenseConnectionEventStreamHandler: eSenseConnectionEventStreamHandler)
        registrar.addMethodCallDelegate(eSenseManagerMethodCallHandler, channel: eSenseManagerMethodChannel);
        
        let eSenseConnectionEventChannel = FlutterEventChannel.init(name: ESenseConnectionEventChannelName, binaryMessenger: registrar.messenger())
        eSenseConnectionEventChannel.setStreamHandler(eSenseConnectionEventStreamHandler)
        
        
    }
    
    // the following is the auto-generated code when creating the plugin -- not used
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}

class ESenseManagerMethodCallHandler: NSObject, FlutterPlugin {
    
    let TIMEOUT = 5 * 1000  // default timeout is set to 5 secs.
    var connected = false
    var samplingRate = 10  // default 10 Hz.
    var manager:ESenseManager? = nil
    var eSenseConnectionEventStreamHandler:ESenseConnectionEventStreamHandler
    
    init(eSenseConnectionEventStreamHandler: ESenseConnectionEventStreamHandler) {
        self.eSenseConnectionEventStreamHandler = eSenseConnectionEventStreamHandler
    }
    
    static func register(with registrar: FlutterPluginRegistrar) {
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var args = call.arguments as? Dictionary<String, String>
        
        switch call.method {
        case "connect":
            let name = args?["name"]
            if name != nil  {
                manager = ESenseManager(deviceName: name! , listener: eSenseConnectionEventStreamHandler)
                connected = manager?.connect(timeout: TIMEOUT) ?? false
                result(connected)
            } else {
                result(FlutterError.init(code: "BAD_ARGS",
                                         message: "Wrong argument - connect expects the name as first argument)" ,
                                         details: nil))
            }
        case "disconnect":
            connected = manager?.disconnect() ?? false
            result(connected)
        case "isConnected":
            connected = manager?.isConnected() ?? false
            result(connected)
        case "setSamplingRate":
            let rate = args?["rate"]
            if rate != nil  {
                samplingRate = Int(rate ?? "10") ?? 10
                result(true)
            } else {
                result(FlutterError.init(code: "BAD_ARGS",
                                         message: "Wrong argument - setSamplingRate expects the sampling rate as first argument)" ,
                                         details: "Sampling rate set to \(samplingRate)"))
            }
        case "getDeviceName":
            let success = manager?.getDeviceName()
            result(success)
        case "setDeviceName":
            let deviceName = args?["deviceName"]
            if deviceName != nil  {
                let success = manager?.setDeviceName(deviceName!)
                result(success)
            } else {
                result(FlutterError.init(code: "BAD_ARGS",
                                         message: "Wrong argument - setDeviceName expects the device name as first argument)" ,
                                         details: nil ))
            }
        case "getBatteryVoltage":
            let success = manager?.getBatteryVoltage()
            result(success)
        case "getAccelerometerOffset":
            let success = manager?.getAccelerometerOffset()
            result(success);
        case "getAdvertisementAndConnectionInterval":
            let success = manager?.getAdvertisementAndConnectionInterval()
            result(success)
        case "setAdvertisementAndConnectiontInterval":
            let advMinInterval:Int = Int((args?["advMinInterval"])!)!
            let advMaxInterval:Int = Int((args?["advMaxInterval"])!)!
            let connMinInterval:Int = Int((args?["connMinInterval"])!)!
            let connMaxInterval:Int = Int((args?["connMaxInterval"])!)!
            let success = manager?.setAdvertisementAndConnectiontInterval(
                advMinInterval,
                advMaxInterval,
                connMinInterval,
                connMaxInterval)
            result(success)
        case "getSensorConfig":
            let success = manager?.getSensorConfig()
            result(success)
        case "setSensorConfig":
            // TODO - implement serialization of ESenseConfig object btw. Swift and Dart.
            result(FlutterMethodNotImplemented)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

class ESenseConnectionEventStreamHandler: NSObject, ESenseConnectionListener, FlutterStreamHandler {
    
    var sink: FlutterEventSink?
    
    /*
     *  FlutterStreamHandler functions below
     */
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    /*
     *  ESenseConnectionListener functions below
     */
    
    func onDeviceFound(_ manager: ESenseManager) {
        sink!("device_found")
    }
    
    func onDeviceNotFound(_ manager: ESenseManager) {
        sink!("device_not_found")
    }
    
    func onConnected(_ manager: ESenseManager) {
        manager.setDeviceReadyHandler { device in
            manager.removeDeviceReadyHandler()
            self.sink!("connected")
        }
    }
    
    func onDisconnected(_ manager: ESenseManager) {
        sink!("disconnected")
    }
}

