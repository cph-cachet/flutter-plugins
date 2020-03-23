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

        // ESense manger method channel
        let  eSenseManagerMethodChannel = FlutterMethodChannel(name: ESenseManagerMethodChannelName, binaryMessenger: registrar.messenger())
        let  eSenseManagerMethodCallHandler =  ESenseManagerMethodCallHandler(eSenseConnectionEventStreamHandler: eSenseConnectionEventStreamHandler)
        registrar.addMethodCallDelegate(eSenseManagerMethodCallHandler, channel: eSenseManagerMethodChannel);
        
        // ESense connection event channel
        let eSenseConnectionEventChannel = FlutterEventChannel.init(name: ESenseConnectionEventChannelName, binaryMessenger: registrar.messenger())
        eSenseConnectionEventChannel.setStreamHandler(eSenseConnectionEventStreamHandler)

        
        // ESense event event channel
        let eSenseEventStreamHandler:ESenseEventStreamHandler = ESenseEventStreamHandler(eSenseManagerMethodCallHandler: eSenseManagerMethodCallHandler)
        let eSenseEventChannel = FlutterEventChannel.init(name: ESenseEventEventChannelName, binaryMessenger: registrar.messenger())
        eSenseEventChannel.setStreamHandler(eSenseEventStreamHandler)

        // ESense sensor event channel
        let eSenseSensorEventStreamHandler:ESenseSensorEventStreamHandler = ESenseSensorEventStreamHandler(eSenseManagerMethodCallHandler: eSenseManagerMethodCallHandler)
        let eSenseSensorEventChannel = FlutterEventChannel.init(name: ESenseSensorEventChannelName, binaryMessenger: registrar.messenger())
        eSenseSensorEventChannel.setStreamHandler(eSenseSensorEventStreamHandler)
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
        let args = call.arguments as? Dictionary<String, String>
        
        switch call.method {
        case "connect":
            let name = args?["name"]
            if name != nil  {
                manager = ESenseManager(deviceName: name! , listener: eSenseConnectionEventStreamHandler)
                connected = manager?.connect(timeout: TIMEOUT) ?? false
                result(connected)
            } else {
                result(FlutterError.init(code: "BAD_ARGS",
                                         message: "Wrong argument - connect expects the name as an argument)" ,
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
                                         message: "Wrong argument - setSamplingRate expects the sampling rate as an argument)" ,
                                         details: "Sampling rate set to default rate: \(samplingRate)"))
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
                                         message: "Wrong argument - setDeviceName expects the device name as an argument)" ,
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

class ESenseEventStreamHandler: NSObject, ESenseEventListener, FlutterStreamHandler {

    var sink: FlutterEventSink?
    var eSenseManagerMethodCallHandler:ESenseManagerMethodCallHandler?
    
    init(eSenseManagerMethodCallHandler: ESenseManagerMethodCallHandler) {
        self.eSenseManagerMethodCallHandler = eSenseManagerMethodCallHandler
    }

    /*
     *  FlutterStreamHandler functions below
     */
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        let success = eSenseManagerMethodCallHandler!.manager?.registerEventListener(self)
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "Listen"
        map["success"] = success
        self.sink!(map)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eSenseManagerMethodCallHandler!.manager?.unregisterEventListener()
        sink = nil
        return nil
    }

    func onBatteryRead(_ voltage: Double) {
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "BatteryRead"
        map["voltage"] = voltage
        self.sink!(map)
    }
    
    func onButtonEventChanged(_ pressed: Bool) {
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "ButtonEventChanged"
        map["pressed"] = pressed
        self.sink!(map)
    }
    
    func onAdvertisementAndConnectionIntervalRead(_ minAdvertisementInterval: Int, _ maxAdvertisementInterval: Int, _ minConnectionInterval: Int, _ maxConnectionInterval: Int) {
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "AdvertisementAndConnectionIntervalRead"
        map["minAdvertisementInterval"] = minAdvertisementInterval
        map["maxAdvertisementInterval"] = maxAdvertisementInterval
        map["minConnectionInterval"] = minConnectionInterval
        map["maxConnectionInterval"] = maxConnectionInterval
        self.sink!(map)
    }
    
    func onDeviceNameRead(_ deviceName: String) {
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "DeviceNameRead"
        map["deviceName"] = deviceName
        self.sink!(map)
    }
    
    func onSensorConfigRead(_ config: ESenseConfig) {
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "SensorConfigRead"
        // right now this event is empty, i.e. we do not serialize and send the config object across
        self.sink!(map)
    }
    
    func onAccelerometerOffsetRead(_ offsetX: Int, _ offsetY: Int, _ offsetZ: Int) {
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "AccelerometerOffsetRead"
        map["offsetX"] = offsetX
        map["offsetY"] = offsetY
        map["offsetZ"] = offsetZ
        self.sink!(map)
    }
}

class ESenseSensorEventStreamHandler: NSObject, ESenseSensorListener, FlutterStreamHandler {

    var sink: FlutterEventSink?
    var eSenseManagerMethodCallHandler:ESenseManagerMethodCallHandler?
    
    init(eSenseManagerMethodCallHandler: ESenseManagerMethodCallHandler) {
        self.eSenseManagerMethodCallHandler = eSenseManagerMethodCallHandler
    }
    
    /*
     *  FlutterStreamHandler functions below
     */

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        eSenseManagerMethodCallHandler!.manager?.registerSensorListener(self, hz: UInt8(eSenseManagerMethodCallHandler!.samplingRate))
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eSenseManagerMethodCallHandler!.manager?.unregisterSensorListener()
        sink = nil
        return nil
    }

    func onSensorChanged(_ evt: ESenseEvent) {
        var map:Dictionary<String,Any> = Dictionary()
        map["type"] = "SensorChanged"
        map["timestamp"] = evt.getTimestamp()
        map["packetIndex"] = evt.getPacketIndex()
        map["accel.x"] = evt.getAccel()[0]
        map["accel.y"] = evt.getAccel()[1]
        map["accel.z"] = evt.getAccel()[2]
        map["gyro.x"] = evt.getGyro()[0]
        map["gyro.y"] = evt.getGyro()[1]
        map["gyro.z"] = evt.getGyro()[2]
        self.sink!(map)
    }
    
}
