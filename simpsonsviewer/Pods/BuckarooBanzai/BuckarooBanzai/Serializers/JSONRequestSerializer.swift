//
//  JsONRequestSerializer.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/24/20.
//

import Foundation

struct JSONRequestSerializer: RequestSerializer {

    func serialize(_ object: Any) throws -> Data {
        
        if !JSONSerialization.isValidJSONObject(object) {
            throw BBError.serializer([NSLocalizedDescriptionKey: "Will not produce a valid JsON object | \(object)."])
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            return jsonData
        } catch let error as NSError {
            throw BBError.serializer(error.userInfo)
        }
    }
}
