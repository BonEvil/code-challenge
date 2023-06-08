//
//  HTTPResponse+ext.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 4/26/23.
//

import UIKit

extension HTTPResponse {

    /// A convenience method to do simple decoding of JSON-structured data returned from the service.
    ///
    /// This method takes a Decodable Generic and tries to parse it into the object provided.
    ///
    /// ```swift
    ///let myObject: MyObject = try response.decodeBodyData()
    /// ```
    /// - Returns: The Decodable object specified or throws an error if there was no data returned or if the data could not be parsed to the specified object.
    public func decodeBodyData<T: Decodable>(convertFromSnakeCase: Bool = false) throws -> T {
        guard let data = body else {
            throw BBError.decoder([NSLocalizedDescriptionKey: "No body data found."])
        }
        let decoder = JSONDecoder()
        if convertFromSnakeCase {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
        let object = try decoder.decode(T.self, from: data)
        return object
    }
    
    /// A convenience method to do simple decoding of image data returned from the service.
    ///
    /// This method is convenient when downloading image assets.
    ///
    /// ```swift
    ///let myNetworkImage = try response.decodeBodyDataAsImage()
    /// ```
    /// - Returns: The network image asset as a ``UIImage`` or throws an error if there was no data returned or if the data could not be parsed to an image.
    public func decodeBodyDataAsImage() throws -> UIImage {
        guard let data = body else {
            throw BBError.decoder([NSLocalizedDescriptionKey: "No body data found."])
        }
        guard let image = UIImage(data: data) else {
            throw BBError.decoder([NSLocalizedDescriptionKey: "Could not create image from data."])
        }
        
        return image
    }
}
