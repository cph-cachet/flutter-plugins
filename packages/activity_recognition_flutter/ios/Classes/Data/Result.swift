//
//  Result.swift
//  activity_recognition_alt
//
//  Created by Daniel Morawetz on 02.08.18.
//

import Foundation

struct Result<T: Codable> : Codable {
    let isSuccessful: Bool
    let data: T?
    let error: ResultError?
    
    static func success <T> (with data: T) -> Result<T> {
        return Result<T>(isSuccessful: true, data: data, error: nil)
    }
    
    static func failure <T> (of type: ResultError.Kind, message: String? = nil, fatal: Bool? = nil) -> Result<T> {
        return Result<T>(isSuccessful: false, data: nil, error: ResultError(type: type, message: message, fatal: fatal))
    }
}

struct ResultError: Codable {
    let type: Kind
    let message: String?
    let fatal: Bool?
    
    enum Kind: String, Codable {
        case runtime = "runtime"
        case locationNotFound = "locationNotFound"
        case permissionDenied = "permissionDenied"
        case serviceDisabled = "serviceDisabled"
    }
}
