//
//  Service.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/24/20.
//

import Foundation

/// ``Service`` objects represent a call to a network service.
/// 
/// They allow you to package up everything you need to call a service.
public protocol Service {
    
    /// An HTTP request method.
    ///
    /// GET, POST, etc. Enumerated as defined in ``HTTPRequestMethod``.
    var requestMethod: HTTPRequestMethod { get }
    
    /// An HTTP accept type.
    ///
    /// "application/json", "html/text", etc. Enumerated as defined in ``HTTPAcceptType``.
    var acceptType: HTTPAcceptType { get }
    
    /// Time interval in seconds.
    ///
    /// The maximum time interval before the request should cancel the service if there has been no response from the server.
    var timeout: TimeInterval { get }
    
    /// The URL for the service as a string.
    ///
    /// i.e. "https://www.example.com/api/user"
    var requestURL: String { get }
    
    /// The content type contained in the body.
    ///
    /// Optional. The "Content-Type" header value. Enumerated as defined in ``HTTPContentType``.
    ///
    /// This is optional since some request types may not have a body. i.e. GET, HEAD, etc.
    var contentType: HTTPContentType? { get }
    
    /// The request body as `Data`.
    ///
    /// Optional. If provided, this `Data` will be used as the request body data without further processing.
    var requestBody: Data? { get }
    
    /// Parameters to be sent as the body of the service call.
    ///
    /// Optional. If included, the parameters will attempt to be serialized with the provided serializer or by the included serializers.
    ///
    /// Currently, only JSON and URL-encoded Form serializers are included.
    var parameters: [AnyHashable: Any]? { get }
    
    /// Header key/value pairs to be included in the HTTP request.
    ///
    /// Optional. If included, will be added to the `HTTPRequest` headers.
    var additionalHeaders: [AnyHashable: Any]? { get }
    
    /// Custom serializer for the request body.
    ///
    /// Optional. If included, will attempt to use this serializer to format the parameters into `Data` to be used in the `HTTPRequest`.
    var requestSerializer: RequestSerializer? { get }
    
    /// The delegate assigned to handle session tasks.
    ///
    /// Optional. If included, can be used to handle authentication challenges, etc.
    var sessionDelegate: URLSessionTaskDelegate? { get }
    
    /// A pre-populated HTTPResponse used for local testing.
    ///
    /// Optional. If included, will be used as a dummy response from a server in order to do local testing of services.
    var testResponse: HTTPResponse? { get }
}
