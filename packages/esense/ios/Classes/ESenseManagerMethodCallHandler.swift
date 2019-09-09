//
//  ESenseManagerMethodCallHandler.swift
//  esense
//
//  Created by Jakob Bardram on 09/09/2019.
//

import Foundation
//import ESense
import Flutter

class ESenseManagerMethodCallHandler: NSObject, FlutterPlugin  {
    
    let TIMEOUT = 5 * 1000  // default timeout is set to 5 secs.
    
    var connected = false
    //var  eSenseConnectionEventStreamHandler: ESenseConnectionEventStreamHandler
    
    var samplingRate = 10  // default 10 Hz.
    //var manager:ESenseManager? = nil
    
    override init() {
    }
    
    static func register(with registrar: FlutterPluginRegistrar) {
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}
