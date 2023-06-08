//
//  HTTPContentType.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/24/20.
//

import Foundation

public enum HTTPContentType {
    case XML
    case JSON
    case FORM
    case CUSTOM(String)
    
    public func string() -> String {
        switch self {
        case .XML: return "application/xml"
        case .JSON: return "application/json"
        case .FORM: return "application/x-www-form-urlencoded"
        case .CUSTOM(let customType): return customType
        }
    }
    
    public static func contentTypeFromString(_ contentTypeString: String) -> HTTPContentType? {
        let contentTypeArray = contentTypeString.components(separatedBy: ";")
        guard let contentType = contentTypeArray.first else {
            return nil
        }
        
        if HTTPContentType.XML.string() == contentType {
            return .XML
        } else if HTTPContentType.JSON.string() == contentType {
            return .JSON
        } else if HTTPContentType.FORM.string() == contentType {
            return .FORM
        } else {
            return .CUSTOM(contentTypeString)
        }
    }
}
