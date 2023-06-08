//
//  CharacterViewer.swift
//  characterviewer
//
//  Created by Daniel Person on 6/7/23.
//

import Foundation
import BuckarooBanzai

public struct CharacterViewerSettings {
    let title: String
    let dataURL: String
    let hostNavigationController: UINavigationController
    
    public init(title: String, dataURL: String, hostNavigationController: UINavigationController) {
        self.title = title
        self.dataURL = dataURL
        self.hostNavigationController = hostNavigationController
    }
}

public class CharacterViewer {
        
    public static var shared: CharacterViewer = {
       return CharacterViewer()
    }()
    
    public var settings: CharacterViewerSettings?
    
    let errorDomain = "CharacterViewerError"
    let characterListViewController = CharacterListViewController()
    
    var characters = [Character]() {
        didSet {
            characterListViewController.characters = characters
        }
    }
    
    private init() { }
    
    public func showCharacterList() throws {
        guard let settings = self.settings else {
            throw NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "No CharacterViewerSettings were found."])
        }
        
        characterListViewController.title = settings.title
        characterListViewController.reloadAction = reloadAction
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            settings.hostNavigationController.viewControllers = [characterListViewController]
        } else {
            let splitViewController = UISplitViewController(style: .doubleColumn)
            splitViewController.modalPresentationStyle = .fullScreen
            let detailViewController = CharacterDetailViewController()
            characterListViewController.detailViewController = detailViewController
            characterListViewController.hideAction = {
                splitViewController.hide(.primary)
            }
            splitViewController.viewControllers = [characterListViewController, detailViewController]
            splitViewController.show(.primary)
            settings.hostNavigationController.topViewController?.present(splitViewController, animated: true)
        }
    }
    
    func retrieveCharacterData(withURL characterDataURL: String) async throws {
        let service = CharacterService(withDataURL: characterDataURL)
        let response = try await BuckarooBanzai.shared.start(service: service)
        let characterResponse: CharacterResponse = try response.decodeBodyData()
        var characters = [Character]()
        characterResponse.RelatedTopics.forEach { relatedTopic in
            let character = Character.createCharacter(fromRelatedTopic: relatedTopic)
            characters.append(character)
        }
        
        self.characters = characters
    }
}

extension CharacterViewer {
    
    private func reloadAction() {
        guard let settings = self.settings else {
            /// SHOW ERROR
            return
        }
        
        Task {
            do {
                try await retrieveCharacterData(withURL: settings.dataURL)
            } catch {
                /// SHOW ERROR
                print("DATA ERROR: \(error)")
            }
        }
    }
}
