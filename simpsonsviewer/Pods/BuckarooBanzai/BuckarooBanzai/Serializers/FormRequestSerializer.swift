//
//  FormRequestSerializer.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/29/20.
//

import Foundation

struct FormRequestSerializer: RequestSerializer {
    
    var customCharacterSet:CharacterSet {
        var charSet = NSCharacterSet.urlQueryAllowed
        let remove = "+&"
        for char in remove.unicodeScalars {
            charSet.remove(char)
        }
        
        return charSet
    }
    
    func serialize(_ object: Any) throws -> Data {
        
        guard let params = object as? [String: Any] else {
            throw BBError.serializer([NSLocalizedDescriptionKey: "Params should be in a one-level Dictionary<String,Any>"])
        }

        var body = ""
        
        for (key,value) in params {
            let encodedKey = urlEncode(key)
            let encodedValue = urlEncode("\(value)")
            body += encodedKey+"="+encodedValue+"&"
        }
        
        body = String(body.dropLast())
        
        if let formData = body.data(using: String.Encoding.utf8) {
            return formData
        } else {
            throw BBError.serializer([NSLocalizedDescriptionKey: "Could not convert string params to Data."])
        }
    }
    
    func urlEncode(_ string:String) -> String {
        guard let encoded = string.addingPercentEncoding(withAllowedCharacters: customCharacterSet) else {
            return string
        }
        
        return encoded
    }
}
