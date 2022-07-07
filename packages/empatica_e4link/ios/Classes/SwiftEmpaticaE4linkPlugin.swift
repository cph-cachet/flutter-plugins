import Flutter
import UIKit

public class SwiftEmpaticaE4linkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "empatica_e4link", binaryMessenger: registrar.messenger())
    let instance = SwiftEmpaticaE4linkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
