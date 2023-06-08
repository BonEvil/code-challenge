//
//  HTTPAcceptType.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/24/20.
//

import Foundation

public enum HTTPAcceptType {
    case XML
    case JSON
    case HTML
    case TEXT
    case JAVASCRIPT
    case ANY
    case CUSTOM(String)
    
    public func string() -> String {
        switch self {
        case .XML: return "application/xml"
        case .JSON: return "application/json"
        case .HTML: return "text/html"
        case .TEXT: return "text/plain"
        case .JAVASCRIPT: return "text/javascript"
        case .ANY: return "*/*"
        case .CUSTOM(let customType): return customType
        }
    }
}
