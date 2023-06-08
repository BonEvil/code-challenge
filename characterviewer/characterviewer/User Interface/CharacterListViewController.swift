//
//  CharacterListViewController.swift
//  characterviewer
//
//  Created by Daniel Person on 6/7/23.
//

import UIKit

class CharacterListViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let nibName = String(describing: CharacterListViewController.self)
        let bundle = Bundle(for: CharacterListViewController.self)
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.showsCancelButton = true
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            reloadAction?()
        }
    }
    
    @IBOutlet weak var refreshButton: UIButton! {
        didSet {
            refreshButton.setTitle("Reload", for: .normal)
        }
    }
        
    var characters = [Character]() {
        didSet {
            filteredCharacters = characters
        }
    }
    
    var filteredCharacters = [Character]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
        }
    }

    var reloadAction: (() -> Void)?
    var hideAction: (() -> Void)?
    var detailViewController: CharacterDetailViewController?
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if refreshButton == sender {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            reloadAction?()
        }
    }
}

extension CharacterListViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        filteredCharacters = characters
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filteredCharacters = characters
            return
        }
        
        var filtered = [Character]()
        
        for character in self.characters {
            if character.name.lowercased().range(of: searchText.lowercased()) != nil ||
                character.description.lowercased().range(of: searchText.lowercased()) != nil {
                filtered.append(character)
            }
        }
        filteredCharacters = filtered
    }
}

extension CharacterListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCharacters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CharacterCell"
        var cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reusableCell
        }
        
        cell.textLabel?.text = filteredCharacters[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = filteredCharacters[indexPath.row]
        
        if let detailViewController = self.detailViewController {
            detailViewController.character = character
            if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
                hideAction?()
            }
        } else {
            let detailView = CharacterDetailViewController()
            detailView.character = character
            self.navigationController?.pushViewController(detailView, animated: true)
        }
    }
}
