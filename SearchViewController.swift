//
//  SearchViewController.swift
//  Hayaku
//
//  Created by Patrick O'Brien on 5/20/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import Siesta

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    var searchController: UISearchController!
    
    var recentSearches: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "recentSearches")
        }
    }

    
    




    

    @IBOutlet var previousSearchesTableView: UITableView!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    

        
        previousSearchesTableView.tableFooterView = UIView()
        let searchResultsController = self.storyboard?.instantiateViewController(withIdentifier: "SearchResults") as? SearchResultsTableViewController
        searchResultsController?.navController = self.navigationController
        searchController = UISearchController(searchResultsController: searchResultsController)
        self.title = "Search"
        searchController.searchBar.placeholder = "Game or Series or Users"
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.previousSearchesTableView.allowsMultipleSelectionDuringEditing = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        previousSearchesTableView.dataSource = self
        previousSearchesTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), !searchText.isEmpty else { return }
        
        previousSearchesTableView.beginUpdates()
        if let previousSearch = recentSearches.index(of: searchText) {
            recentSearches.remove(at: previousSearch)
            previousSearchesTableView.moveRow(at: IndexPath(row: previousSearch, section: 0), to: IndexPath(row: 0 , section: 0))
        } else {
            previousSearchesTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
        }
        recentSearches.insert(searchText, at: 0)
        
        if recentSearches.count > 7 {
            recentSearches.remove(at: recentSearches.count - 1)
            previousSearchesTableView.deleteRows(at: [IndexPath(row: recentSearches.count - 1, section: 0)], with: .bottom)
        }
        previousSearchesTableView.endUpdates()
        
        
        
    }
    


    
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        if searchText != "" {

            APIManager.sharedInstance.getResultsSeries(searchText: searchText, completion: {
                result in
                DispatchQueue.main.async {
                    if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                        switch result {
                        case.success(let series):
                            resultsController.series = series
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            })
        
            APIManager.sharedInstance.getResultsGames(searchText: searchText, completion: {
                result in
                DispatchQueue.main.async {
                    if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                        switch result {
                        case.success(let games):
                            resultsController.games = games
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            })
            
            APIManager.sharedInstance.getResultsUsers(searchText: searchText, completion: {
                result in
                DispatchQueue.main.async {
                    if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                        switch result {
                        case.success(let users):
                            resultsController.users = users
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            })
            
            
        } else {
            if let resultsController = searchController.searchResultsController as? SearchResultsTableViewController {
                resultsController.games = []
                resultsController.series = []
                resultsController.users = []
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 50
        let cell = previousSearchesTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = recentSearches[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 120/255, green: 0/255, blue: 237/255, alpha: 1.0)
        cell.textLabel?.font = cell.textLabel!.font.withSize(20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            recentSearches.remove(at: indexPath.row)
            previousSearchesTableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.text = recentSearches[indexPath.row]
        let tappedSearch = recentSearches[indexPath.row]
        recentSearches.remove(at: indexPath.row)
        recentSearches.insert(tappedSearch, at: 0)
        searchController.isActive = true
        previousSearchesTableView.reloadData()
    }
    



}


























class SearchResultsTableViewController: UITableViewController {
    
    var navController : UINavigationController?
    let identities = ["SeriesView", "GameView"]
    
    var games = [ResultsGame]() {
        didSet {
            update(for: .games, isEmpty: games.isEmpty, prepend: false)
        }
    }
    
    var series = [ResultsSeries]() {
        didSet {
            update(for: .series, isEmpty: series.isEmpty, prepend: true)
        }
    }
    
    var users = [ResultsUsers]() {
        didSet {
            update(for: .users, isEmpty: users.isEmpty, prepend: true)
        }
    }
    
    var sections = [Section]()
    
    enum Section {
        
        case users
        case series
        case games
        
        var header : String {
            switch self {
                case .users : return "Users"
                case .series: return "Series"
                case .games : return "Games"
                
            }
        }
        
        var cellIdentifier : String {
            switch self {
                case .users : return "UsersTableViewCell"
                case .series: return "SeriesTableViewCell"
                case .games: return "GamesTableViewCell"
                
            }
        }
        
    }
    
    
    
    func update(for section: Section, isEmpty: Bool, prepend: Bool) {
        if let index = sections.firstIndex(of: section) {
            if isEmpty {
                sections.remove(at: index)
                tableView.deleteSections(IndexSet(integer: index), with: .fade)
            } else {
                tableView.reloadSections(IndexSet(integer: index), with: .fade)
            }
        } else {
        
            if !isEmpty {
                if prepend {
                    sections.insert(section, at: 0)
                } else {
                    sections.append(section)
                }
                if let index = sections.firstIndex(of: section) {
                    tableView.insertSections(IndexSet(integer: index), with: .fade)
                }
            }
        }
    }
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let view = UIView()
        tableView.tableFooterView = view
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch sections[section] {
            case .users : return users.count
            case .series: return series.count
            case .games: return games.count
    
            
            
        }
    }
    

    override func tableView(_ tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 100))
        let label = UILabel()
        label.text = sections[section].header
        label.font = UIFont(name: "Menlo", size: 18)
        label.frame = CGRect(x: 10, y: 3, width: tableView.bounds.width - 10, height: 18)
        headerView.addSubview(label)
        headerView.backgroundColor = UIColor(red: 174/255, green: 152/255, blue: 249/255, alpha: 1)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableView.sectionHeaderHeight = 50
    
        switch sections[section] {
            case .users: return sections[section].header
            case .series: return sections[section].header
            case .games: return sections[section].header
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.rowHeight = 95
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as! GameResultTableViewCell
        let imageSize = cell.imageView!.bounds.size.applying(CGAffineTransform(scaleX: self.traitCollection.displayScale, y: self.traitCollection.displayScale))

        switch sections[indexPath.section] {
        case .users:
            cell.resultsLabel?.text = users[indexPath.row].names.international
            cell.resultsImageView.image = UIImage(systemName: "person")
            
        case .series:
            cell.resultsLabel.text = series[indexPath.row].names.international
            let url = URL(string: (series[indexPath.row].assets.cover(for: imageSize)?.uri)!)
            cell.resultsImageView.kf.setImage(with: url)

        case .games:
            cell.resultsLabel?.text = games[indexPath.row].names.international
            let url = URL(string: (games[indexPath.row].assets.cover(for: imageSize)?.uri)!)
            cell.resultsImageView.kf.setImage(with: url)


            
            

        }

        return cell
    }
    
    
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "GameSegue" {
//            let gameViewController = segue.destination as? GameViewController
//            if games.count == 0 {
//
//            } else if series.count == 0 {
//
//            }
//            if let indexPath = tableView.indexPath(for: sender as! GameResultTableViewCell) {
//                print(indexPath)
//                gameViewController?.gameId = games[indexPath.row].id
//            }
//        } else {
//            let seriesViewController = segue.destination as? SeriesViewController
//            if let indexPath = tableView.indexPath(for: sender as! GameResultTableViewCell) {
//                print(indexPath)
//                seriesViewController?.seriesId = series[indexPath.row].id
//            }
//        }
//    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .series:
            let seriesViewController = storyboard?.instantiateViewController(withIdentifier: "SeriesView") as? SeriesViewController
            seriesViewController?.series = series[indexPath.row]
            seriesViewController?.seriesName = series[indexPath.row].names.international
            self.navController?.pushViewController(seriesViewController!, animated: true)
            
        case .games :
            let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameView") as? GameViewController
            gameViewController?.resultsGame = games[indexPath.row]
            self.navController?.pushViewController(gameViewController!, animated: true)
        case .users :
            let userViewController = storyboard?.instantiateViewController(withIdentifier : "UserView") as? UserViewController
            userViewController?.user = users[indexPath.row]
            self.navController?.pushViewController(userViewController!, animated: true)
        }
    }
    
    
    
    override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
        print(action)
        if action == #selector(show(_:sender:)) {
            return navController
        }
        return super.targetViewController(forAction: action, sender: sender)
    }
    
}



