//
//  HTTPRequestMethod.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/24/20.
//

import Foundation

public enum HTTPRequestMethod
{
    case GET
    case POST
    case PUT
    case DELETE
    case HEAD
    case CONNECT
    case OPTIONS
    case PATCH
    case QUERY
    case TRACE
    case CUSTOM(String)
    
    public func string() -> String {
        switch self {
        case .CUSTOM(let customType): return customType
        default: return "\(self)"
        }
    }
}
