//
//  CharacterResponse.swift
//  characterviewer
//
//  Created by Daniel Person on 6/7/23.
//

import Foundation

struct CharacterResponse: Codable {
    let RelatedTopics: [RelatedTopic]
}

struct RelatedTopic: Codable {
    let FirstURL: String
    let Icon: Icon
    let Text: String
}

struct Icon: Codable {
    let URL: String
}
