//
//  Codec.swift
//  activity_recognition
//
//  Created by RESI Relate People on 03.08.18.
//

import Foundation

class Codec {
    static func encodeResult(activity: Activity) -> String {
        return "{\"type\":\"\(activity.type)\", \"confidence\":\(activity.confidence)}"
    }
}
