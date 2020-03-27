//
//  Activity.swift
//  activity_recognition_alt
//
//  Created by Daniel Morawetz on 02.08.18.
//

import Foundation
import CoreMotion

class Activity: Codable {
    let type: String
    let confidence: Int
    
    init(from activity: CMMotionActivity) {
        switch true {
        case activity.stationary:
            self.type = "STILL"
        case activity.walking:
            self.type = "WALKING"
        case activity.running:
            self.type = "RUNNING"
        case activity.automotive:
            self.type = "IN_VEHICLE"
        case activity.cycling:
            self.type = "ON_BICYCLE"
        default:
            self.type = "UNKNOWN"
        }
        
        switch activity.confidence {
        case CMMotionActivityConfidence.low:
            self.confidence = 10
        case CMMotionActivityConfidence.medium:
            self.confidence = 50
        case CMMotionActivityConfidence.high:
            self.confidence = 100
        }
    }

}
