import Flutter
import UIKit

@available(iOS 9.0, *)
public class SwiftActivityRecognitionFlutterPlugin: NSObject, FlutterPlugin {
    internal let registrar: FlutterPluginRegistrar
    private let activityClient = ActivityClient()
    private let activityChannel: ActivityChannel
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.activityChannel = ActivityChannel(activityClient: activityClient)
        super.init()
        
        activityChannel.register(on: self)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        _ = SwiftActivityRecognitionFlutterPlugin(registrar: registrar)
    }
}
