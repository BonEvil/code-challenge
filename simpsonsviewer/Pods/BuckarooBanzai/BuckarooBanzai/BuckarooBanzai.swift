//
//  BuckarooBanzai.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/24/20.
//

import Foundation

/// The main object for calling network services.
///
/// Create a singleton instance for all your networking calls.
///  ```swift
///  BuckarooBanzai.sharedInstance()
///  ```
open class BuckarooBanzai: NSObject {
    
    /// Singleton instance
    public static var shared: BuckarooBanzai = {
       return BuckarooBanzai()
    }()
    
    /// Domain for errors thrown in ``BuckarooBanzai``
    static let errorDomain = "BuckarooBanzaiErrorDomain"
    
    /// Key for retrieving the ``HTTPResponse`` object from the `userInfo` dictionary of a thrown error, if available
    ///
    /// ```swift
    /// if let response = error.httpResponse() {}
    /// ```
    static let BBHTTPResponseErrorKey = "_bbHttpResponseErrorKey"
    
    /// Key for retrieving the HTTP status code from the `userInfo` dictionary of a thrown error
    ///
    /// ```swift
    /// if let statusCode = error.httpStatusCode() {}
    /// ```
    static let BBHTTPStatusCodeErrorKey = "_bbHttpStatusCodeErrorKey"
    
    /// Name of the operation queue for the URLSession object
    static let OperationQueueName = "BuckarooQueue"
    
    /// The queue on which network calls will run
    ///
    /// Since this is a dedicated queue, make sure to do UI updates on the main queue.
    lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = BuckarooBanzai.OperationQueueName
        queue.maxConcurrentOperationCount = 4
        return queue
    }()
    
    /// The dedicated session used for network calls
    fileprivate var session: Foundation.URLSession!
    
    private override init() {
        super.init()
        createSession()
    }
    
    /// Creates a new session running on the dedicated `OperationQueue`
    fileprivate func createSession() {
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
    }
    
    /// Invalidate and cancel the current `URLSession` and instantiate a new instance
    ///
    /// This method is particularly useful because of the nature of a `URLSession` to hold on to the last used credentials when answering a `URLAuthenticationChallenge`.
    ///
    /// Since the initial challenge is an expensive operation, the session will simply re-use the existing handshake for a certain period of time (up to 10 minutes in some cases) even if the challenge credentials are changed.
    /// i.e. Such as when switching users within the same app.
    public func resetSession() {
        session.invalidateAndCancel()
        session = nil
        createSession()
    }
    
    /// Starts a network ``Service`` asynchronously
    ///
    /// This async/await method returns an instance of ``HTTPResponse`` that will house the relevant information to be used in further processing.
    ///
    /// ```swift
    /// let service = CustomService()
    /// let response = try await BuckarooBanzai.sharedInstance().start(service: service)
    /// ```
    ///
    /// - Parameter service: The configured service object.
    /// - Returns: An ``HTTPResponse`` object or throws an error based on the expected response.
    public func start(service: Service) async throws -> HTTPResponse {
        if let testResponse = service.testResponse {
            let response = try doTestResponse(testResponse, withAcceptType: service.acceptType)
            return response
        }
        
        let request = try createRequest(service)
        let response = try await sendRequest(request, forService: service)
        return response
    }
    
    /// Off-network testing
    ///
    /// If a ``Service/testResponse`` is set in the ``Service`` object, an off-network process is run to validate and return the ``HTTPResponse`` provided,
    ///
    /// - Parameters:
    ///   - httpResponse: The pre-constructed ``HTTPResponse`` object used to simulate a network call response
    ///   - acceptType: The ``HTTPAcceptType`` that the caller is expecting from this service
    /// - Returns: The ``HTTPResponse`` provided or throws an error based on information contained in the response
    fileprivate func doTestResponse(_ httpResponse: HTTPResponse, withAcceptType acceptType: HTTPAcceptType) throws -> HTTPResponse {
        do {
            try checkStatusCode(httpResponse.statusCode)
            try checkContentType(contentType(fromHeaders: httpResponse.headers), forAcceptType: acceptType.string())
            return httpResponse
        } catch let error as BBError {
            if var userInfo = error.userInfo {
                userInfo[BuckarooBanzai.BBHTTPResponseErrorKey] = httpResponse
                throw error.updateUserInfoWith(userInfo: userInfo)
            }
            throw error
        }
    }
    
    fileprivate func createRequest(_ service: Service) throws -> URLRequest {
        let request = NSMutableURLRequest()
        request.url = URL(string: service.requestURL)
        request.httpMethod = service.requestMethod.string()
        request.timeoutInterval = service.timeout
        
        if let additionalHeaders = service.additionalHeaders {
            for (key,value) in additionalHeaders {
                request.setValue("\(value)", forHTTPHeaderField: "\(key)")
            }
        }
        
        if let contentType = service.contentType {
            request.setValue(contentType.string(), forHTTPHeaderField: "Content-Type")
        }
        request.setValue(service.acceptType.string(), forHTTPHeaderField: "Accept")
        
        /// If the service already has the request body as `Data`, just add it to the request and return
        if let body = service.requestBody {
            request.httpBody = body
            return request as URLRequest
        }
        
        /// Try to serialize the the request parameters to form the `request.httpBody` `Data`
        do {
            let data = try serializeRequest(forService: service)
            request.httpBody = data
            return request as URLRequest
        } catch let error as BBError {
            throw error
        }
    }
    
    fileprivate func sendRequest(_ request: URLRequest, forService service: Service) async throws -> HTTPResponse {
        let (data, response) = try await session.data(for: request, delegate: service.sessionDelegate)
        
        guard let httpUrlResponse = response as? HTTPURLResponse else {
            throw BBError.general([NSLocalizedDescriptionKey : "Invalid response."])
        }
        
        let allHeaderFields = httpUrlResponse.allHeaderFields
        let statusCode = httpUrlResponse.statusCode
        let httpResponse = HTTPResponse(statusCode: statusCode, headers: allHeaderFields, body: data)
        let receivedContentType = self.contentType(fromHeaders: allHeaderFields)
        let acceptType = service.acceptType.string()
        
        do {
            try checkStatusCode(statusCode)
            try checkContentType(receivedContentType, forAcceptType: acceptType)
            return httpResponse
        } catch let error as BBError {
            var additionalInfo: [String: Any] = [BuckarooBanzai.BBHTTPResponseErrorKey: httpResponse]
            guard let userInfo = error.userInfo else {
                throw error.updateUserInfoWith(userInfo: additionalInfo)
            }
            additionalInfo.merge(userInfo) { (current, _) in
                current
            }
            throw error.updateUserInfoWith(userInfo: userInfo)
        }
    }
    
    fileprivate func checkStatusCode(_ statusCode: Int) throws {
        if statusCode < 200 || statusCode >= 300 {
            throw BBError.statusCode([NSLocalizedDescriptionKey: "Status code not OK: \(statusCode)", BuckarooBanzai.BBHTTPStatusCodeErrorKey: statusCode])
        }
    }
    
    fileprivate func checkContentType(_ receivedContentType: String, forAcceptType acceptType: String) throws {
        if acceptType != HTTPAcceptType.ANY.string() && receivedContentType != acceptType {
            throw BBError.contentType([NSLocalizedDescriptionKey: "Expecting Content-Type [\(acceptType)] but got [\(receivedContentType)]"])
        }
    }
    
    fileprivate func contentType(fromHeaders headers: [AnyHashable: Any]) -> String {
        
        guard let contentTypeHeader = headers["Content-Type"] as? String else {
            return ""
        }
        
        let contentTypeArray = contentTypeHeader.components(separatedBy: ";")
        if contentTypeArray.count > 0 {
            return contentTypeArray[0]
        }
        
        return ""
    }
    
    /// Checks to see of the `Service.requestBody` is a `Dictionary<AnyHashable: Any>` and try to process it if it is.
    ///
    /// This method uses the provided serializer if available, otherwise, sends the `parameters` object on to see if it can be parsed by the included serializers.
    ///
    /// Currently, only JSON and URL-encoded Form serializers are included.
    ///
    /// - Parameters:
    ///   - service: The configured service object.
    /// - Returns: `Data` created by the serializer, `nil` if there weren't any parameters or if the `Service.contentType` was not set or throws an error produced by the serializer.
    fileprivate func serializeRequest(forService service: Service) throws -> Data? {
        
        guard let parameters = service.parameters, parameters.count > 0 else {
            return nil
        }
        
        if let serializer = service.requestSerializer  {
            return try serializeRequestParams(parameters, withCustomSerializer: serializer)
        } else {
            return try serializeRequestParams(parameters, forContentType: service.contentType)
        }
    }
    
    /// Custom serializer processing
    ///
    /// If a `Service.requestSerializer` is provided, this method attempts to use it to serialize the `Service.parameters`.
    ///
    /// - Parameters:
    ///   - requestParams: The `Service.parameters` for the network call.
    ///   - serializer: The custom serializer conforming to the `RequestSerializer` protocol.
    /// - Returns: A `Data` representation of the serialized parameters, `nil`, or throws an error if the task could not be completed.
    fileprivate func serializeRequestParams(_ requestParams: Any, withCustomSerializer serializer: RequestSerializer) throws -> Data? {
        do {
            let data = try serializer.serialize(requestParams as Any)
            return data
        } catch let error as NSError {
            throw BBError.serializer(error.userInfo)
        }
    }
        
    fileprivate func serializeRequestParams(_ requestParams: Any, forContentType contentType: HTTPContentType?) throws -> Data? {
        guard let contentType = contentType else {
            return nil
        }

        switch contentType {
        case .JSON:
            return try serializeJsonFromRequestParams(requestParams)
        case .FORM:
            return try serializeFormFromRequestParams(requestParams)
        default:
            throw BBError.serializer([NSLocalizedDescriptionKey: "No default serializer for content type: \(contentType.string())"])
        }
    }
    
    fileprivate func serializeJsonFromRequestParams(_ requestParams: Any) throws -> Data? {
        do {
            let data = try JSONRequestSerializer().serialize(requestParams)
            return data
        } catch let error as NSError {
            throw BBError.serializer(error.userInfo)
        }
    }
    
    fileprivate func serializeFormFromRequestParams(_ requestParams: Any) throws -> Data? {
        do {
            let data = try FormRequestSerializer().serialize(requestParams)
            return data
        } catch let error as NSError {
            throw BBError.serializer(error.userInfo)
        }
    }
}
