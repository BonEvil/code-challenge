//
//  ViewController.swift
//  simpsonsviewer
//
//  Created by Daniel Person on 6/7/23.
//

import UIKit
import CharacterViewer

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let navController = self.navigationController else {
            return
        }
        
        let characterViewer = CharacterViewer.shared
        
        let settings = CharacterViewerSettings(title: "The Simpsons", dataURL: "https://api.duckduckgo.com/?q=simpsons+characters&format=json", hostNavigationController: navController)
        characterViewer.settings = settings
        do {
            try characterViewer.showCharacterList()
        } catch {
            print("CHARACTERVIEWER ERROR: \(error)")
        }
    }
}
