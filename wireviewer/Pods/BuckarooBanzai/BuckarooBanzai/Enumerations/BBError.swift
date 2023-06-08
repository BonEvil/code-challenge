//
//  BBError.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 2/7/22.
//

import Foundation

public enum BBError: Error {
    case general(_ userInfo: [String: Any]?)
    case statusCode(_ userInfo: [String: Any]?)
    case contentType(_ userInfo: [String: Any]?)
    case serializer(_ userInfo: [String: Any]?)
    case parser(_ userInfo: [String: Any]?)
    case decoder(_ userInfo: [String: Any]?)
    
    public func updateUserInfoWith(userInfo: [String: Any]?) -> BBError {
        switch self {
        
        case .general(_):
            return BBError.general(userInfo)
        case .statusCode(_):
            return BBError.statusCode(userInfo)
        case .contentType(_):
            return BBError.contentType(userInfo)
        case .serializer(_):
            return BBError.serializer(userInfo)
        case .parser(_):
            return BBError.parser(userInfo)
        case .decoder(_):
            return BBError.decoder(userInfo)
        }
    }
}

extension BBError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case
            .general(let userInfo),
            .statusCode(let userInfo),
            .contentType(let userInfo),
            .serializer(let userInfo),
            .parser(let userInfo),
            .decoder(let userInfo):
                if let localizedDescription = userInfo?[NSLocalizedDescriptionKey] as? String {
                    return localizedDescription
                }
                
                return nil
        }
    }
}

extension BBError {
    public var userInfo: [String: Any]? {
        get {
            switch self {
                case
                .general(let userInfo),
                .statusCode(let userInfo),
                .contentType(let userInfo),
                .serializer(let userInfo),
                .parser(let userInfo),
                .decoder(let userInfo):
                    return userInfo
            }
        }
    }
}

extension BBError {
    public func httpResponse() -> HTTPResponse? {
        if let userInfo = self.userInfo, let response = userInfo[BuckarooBanzai.BBHTTPResponseErrorKey] as? HTTPResponse {
            return response
        }
        
        return nil
    }
    
    public func httpStatusCode() -> Int? {
        if let userInfo = self.userInfo, let statusCode = userInfo[BuckarooBanzai.BBHTTPStatusCodeErrorKey] as? Int {
            return statusCode
        }
        
        return nil
    }
}
