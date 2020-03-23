//
//  ActivityClient.swift
//  activity_recognition_alt
//
//  Created by Daniel Morawetz on 02.08.18.
//

import Foundation

@available(iOS 9.0, *)
class ActivityChannel {
    
    private let activityClient: ActivityClient
    private let activityUpdatesHandler: ActivityUpdatesHandler
    
    init(activityClient: ActivityClient) {
        self.activityClient = activityClient
        self.activityUpdatesHandler = ActivityUpdatesHandler(activityClient: activityClient)
    }
    
    func register(on plugin: SwiftActivityRecognitionFlutterPlugin) {
        let methodChannel = FlutterMethodChannel(name: "activity_recognition/activities", binaryMessenger: plugin.registrar.messenger())
        methodChannel.setMethodCallHandler(handleMethodCall(_:result:))
        
        let eventChannel = FlutterEventChannel(name: "activity_recognition/activityUpdates", binaryMessenger: plugin.registrar.messenger())
        eventChannel.setStreamHandler(activityUpdatesHandler)
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startActivityUpdates":
            startActivityUpdates()
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startActivityUpdates() {
        activityClient.resume()
    }
    
    class ActivityUpdatesHandler: NSObject, FlutterStreamHandler {
        private let activityClient: ActivityClient
        
        init(activityClient: ActivityClient) {
            self.activityClient = activityClient
        }
        
        public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            activityClient.registerActivityUpdates { result in
                events(Codec.encodeResult(activity: result.data!))
            }
            return nil
        }
        
        public func onCancel(withArguments arguments: Any?) -> FlutterError? {
            activityClient.deregisterActivityUpdatesCallback()
            return nil
        }
    }
}
