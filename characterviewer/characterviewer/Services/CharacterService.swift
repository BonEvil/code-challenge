//
//  CharacterService.swift
//  characterviewer
//
//  Created by Daniel Person on 6/7/23.
//

import BuckarooBanzai

struct CharacterService: Service {
    var requestMethod: HTTPRequestMethod = .GET
    var acceptType: HTTPAcceptType = .ANY
    var timeout: TimeInterval = 10
    var requestURL: String
    var contentType: HTTPContentType?
    var requestBody: Data?
    var parameters: [AnyHashable : Any]?
    var additionalHeaders: [AnyHashable : Any]?
    var requestSerializer: RequestSerializer?
    var sessionDelegate: URLSessionTaskDelegate?
    var testResponse: HTTPResponse?
    
    init(withDataURL url: String) {
        requestURL = url
    }
}
