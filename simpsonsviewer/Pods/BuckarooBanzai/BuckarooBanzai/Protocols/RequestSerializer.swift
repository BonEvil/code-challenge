//
//  RequestSerializer.swift
//  BuckarooBanzai
//
//  Created by Daniel Person on 9/24/20.
//

import Foundation

public protocol RequestSerializer {
    
    func serialize(_ object: Any) throws -> Data
}
