//
//  ActivityClient.swift
//  activity_recognition
//
//  Created by Daniel Morawetz on 02.08.18.
//

import Foundation
import CoreMotion

class ActivityClient {
    
    private let activityManager = CMMotionActivityManager()
    private var activityUpdatesCallback: ActivityUpdatesCallback? = nil
    
    private var isPaused = true
    
    public func resume() {
        guard isPaused else {
            return
        }
        
        activityManager.startActivityUpdates(to: OperationQueue.init()) { (activity) in
            if (activity != nil) {
                self.activityUpdatesCallback?(Result<Activity>.success(with: Activity(from:activity!)))
            }
        }
        
        isPaused = false
    }
    
    public func pause() {
        guard !isPaused else {
            return
        }
        
        activityManager.stopActivityUpdates()
        
        isPaused = true
    }
    
    public func registerActivityUpdates(callback: @escaping ActivityUpdatesCallback) {
        activityUpdatesCallback = callback
    }
    
    public func deregisterActivityUpdatesCallback() {
        activityUpdatesCallback = nil
    }
    
    typealias ActivityUpdatesCallback = (Result<Activity>) -> Void
}
