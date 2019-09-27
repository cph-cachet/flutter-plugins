import Flutter
import UIKit
//import esense

public class SwiftEsensePlugin: NSObject, FlutterPlugin {
    
    static let ESenseManagerMethodChannelName = "esense.io/esense_manager";
    static let ESenseConnectionEventChannelName = "esense.io/esense_connection";
    static let ESenseEventEventChannelName = "esense.io/esense_events";
    static let ESenseSensorEventChannelName = "esense.io/esense_sensor";
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        // the following is the auto-generated code when creating the plugin -- not used
        let channel = FlutterMethodChannel(name: "esense", binaryMessenger: registrar.messenger())
        let instance = SwiftEsensePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // eSense implementation below
        
        // ESenseManger Method Channel
        let  eSenseManagerMethodChannel = FlutterMethodChannel(name: ESenseManagerMethodChannelName, binaryMessenger: registrar.messenger())
        let  eSenseManagerMethodCallHandler =  ESenseManagerMethodCallHandler()
        registrar.addMethodCallDelegate(eSenseManagerMethodCallHandler, channel: eSenseManagerMethodChannel);


    
        
    }
    
    // the following is the auto-generated code when creating the plugin -- not used
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}
