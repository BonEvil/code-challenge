//
//  HTTPResponse.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/25/20.
//

import Foundation

public struct HTTPResponse {
    
    /// The HTTP status code returned from the service call.
    public var statusCode: Int
    
    /// Any key/value pairs returned in the header from the service call.
    public var headers: [AnyHashable: Any]
    
    /// The data returned in the body from the service call.
    public var body: Data?
    
    /// Default initializer for the repsonse object
    /// - Parameters:
    ///   - statusCode: Will hold the HTTP status code returned from the service call.
    ///   - headers: Will hold any key/value pairs returned in the header from the service call.
    ///   - body: Will hold the data returned in the body from the service call.
    public init(statusCode: Int, headers: [AnyHashable: Any], body: Data? = nil) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}
