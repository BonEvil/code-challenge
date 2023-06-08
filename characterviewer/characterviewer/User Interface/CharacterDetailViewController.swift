//
//  CharacterDetailViewController.swift
//  characterviewer
//
//  Created by Daniel Person on 6/7/23.
//

import UIKit
import BuckarooBanzai

class CharacterDetailViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let nibName = String(describing: CharacterDetailViewController.self)
        let bundle = Bundle(for: CharacterDetailViewController.self)
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = UIImage.init(systemName: "person.fill")
            imageView.tintColor = .gray
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.borderWidth = 1.0
            loadImage()
        }
    }
    
    @IBOutlet weak var detailLabel: UILabel! {
        didSet {
            detailLabel.text = character?.description
        }
    }
    
    var character: Character?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let character = character {
            self.title = character.name
        }
    }
    
    private func loadImage() {
        guard let character = character else {
            return
        }
        print("\(character.imageURL)")
        let service = CharacterService(withDataURL: character.imageURL)
        Task {
            do {
                let response = try await BuckarooBanzai.shared.start(service: service)
                let image = try response.decodeBodyDataAsImage()
                imageView.image = image
            }
        }
    }
}
