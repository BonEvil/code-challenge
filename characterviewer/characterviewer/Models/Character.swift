//
//  Character.swift
//  characterviewer
//
//  Created by Daniel Person on 6/7/23.
//

import Foundation

public struct Character {
    let name: String
    var imageURL: String
    let description: String
    
    static func createCharacter(fromRelatedTopic topic: RelatedTopic) -> Character {
        let nameArray = topic.Text.components(separatedBy: " - ")
        var name = "Unknown"
        var description = ""
        if nameArray.count > 1 {
            name = String(nameArray[0])
            description = String(topic.Text.suffix(from: "\(name) - ".endIndex))
        }
        
        let imageURL = "https://duckduckgo.com" + topic.Icon.URL
        
        return Character(name: name, imageURL: imageURL, description: description)
    }
}
