//
//  GameViewController.swift
//  Hayaku
//
//  Created by Patrick O'Brien on 10/2/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.


import UIKit
import Siesta
import Alamofire
import Kanna


class GameViewController: UITableViewController {
    
    let favoriteButton = UIButton(type: .system)
    let unfavoriteButton = UIButton(type: .system)
    


    var resultsGame : ResultsGame?
    var streams = [Stream]()
    var seriesId: String?
    var gameName : String?
    var game : Game?
    var seriesName : String?
    var categories = [Category]()


    //MARK: animateGameViewStuff
    
    
    func animateGameViewStuff() {
        UIView.animate(withDuration: 1.0, animations: {
            self.gameImageView.alpha = 1
            self.seriesNameLabel.alpha = 1
            self.releasedLabel.alpha = 1
            self.platformsLabel.alpha = 1
        })
    }
    
    let testView = UIView()

    
    
    //MARK: setBarButtonItems
    
    
    func setBarButtonItems() {
        favoriteButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        favoriteButton.imageView?.contentMode = .scaleAspectFit
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        
        
        unfavoriteButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
        unfavoriteButton.imageView?.contentMode = .scaleAspectFit
        unfavoriteButton.addTarget(self, action: #selector(unfavoriteButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        
        setBarButtonItems()
        
        
        tableView.sectionHeaderHeight = 50

        
        
        
        
        
        
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        streamsButton.isEnabled = false
        tableView.tableFooterView = UIView()
        
 
        
        gameImageView.alpha = 0
        seriesNameLabel.alpha = 0
        releasedLabel.alpha = 0
        platformsLabel.alpha = 0

        
        


        
        
        seriesNameLabel.textColor = UIColor(red: 120/255, green: 0/255, blue: 237/255, alpha: 1.0)
        
        
        
        
        if game == nil && gameName == nil {
            
            // If coming from the Search or Series View Controller.
            
            guard let resultGame = resultsGame else { return }
            
            APIManager.sharedInstance.getGameForGameView(gameInformation: resultGame.id, popularController: false, completion: {
                result in
                
                switch result {
                case .success(let data):
                    do {
                        let gameData = try JSONDecoder().decode(GamesResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.setGameInformation(game: gameData.data)
                        }                        
                    } catch let error {
                        print(error)
                    }
                    case .failure(let error):
                        print(error)
                    }
                }
                
            )
            
        } else if game != nil && gameName == nil {
 
    
            //If coming from the Favorites View Controller.
            
            
            
            if let game = game {
                
                APIManager.sharedInstance.getGameForGameView(gameInformation: game.id, popularController: false, completion: {
                    result in
                    
                    switch result {
                    case .success(let data):
                        do {
                            let gameData = try JSONDecoder().decode(GamesResponse.self, from: data)
                            DispatchQueue.main.async {
                                self.setGameInformation(game: gameData.data)
                            }
                        } catch let error {
                            print(error)
                        }
                        case .failure(let error):
                            print(error)
                        }
                    }
                    
                )

            }
            self.animateGameViewStuff()

            
        } else {
            
            //If coming from the PopularGamesCollectionViewController
            
            APIManager.sharedInstance.getGameForGameView(gameInformation: gameName ?? "", popularController: true, completion: {
                result in
                switch result {
                 case .success(let data):
                     do {
                         let gameData = try JSONDecoder().decode(PopularGamesResponse.self, from: data)
                         DispatchQueue.main.async {
                             self.setGameInformation(game: gameData.data[0])
                         }
                     } catch let error {
                         print(error)
                     }
                     case .failure(let error):
                         print(error)
                     }
                
            })
    
        }
    }
    
    

    // MARK: setGameInformation
    
    
    func setGameInformation(game: Game) {
        
        self.game = game
        self.title = game.names.international
        self.getSeriesName(seriesUrl: String(describing: game.links[6].uri))
        self.seriesNameLabel.text = self.seriesName
        let urlString = self.game!.assets.coverSmall.uri
        let stringArray = urlString.components(separatedBy: "/")
        self.getStreams(string: stringArray[4])
        for category in game.categories!.data {
            for link in category.links {
                if link.rel == "leaderboard" {
                    self.categories.append(category)

                }
            }
        }
        
        if let url = URL(string: (game.assets.coverMedium.uri)) {
            self.gameImageView.kf.setImage(with: url)
            self.gameImageView.layer.shadowColor = UIColor.black.cgColor
            self.gameImageView.layer.shadowOpacity = 0.25
            self.gameImageView.layer.shadowOffset = CGSize(width: 3, height: 3)
        }
        self.tableView.reloadData()
        if let platforms = game.platforms?.data {
            self.setPlatforms(platforms: platforms)
        }
        
        for category in (game.categories?.data)! {
            for link in category.links {
                if link.rel == "leaderboard" {
                    self.categories.append(category)
                    
                }
            }
        }
        
        
        let  releaseDateArray = game.releaseDate.components(separatedBy: "-")
        self.releasedLabel.text = releaseDateArray[0]
        
        
        
        for favGame in FavoritesManager.shared.favorites {
            if self.game?.id == favGame.id {
                print("Game Found")
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.unfavoriteButton)
            }
        }
        self.animateGameViewStuff()
            
            
    }
    
    
    
    
    
    
    
    
    
    //MARK: setPlatforms
    
    
    func setPlatforms(platforms: [Platforms]) {
        
        var platformString = ""
        for (index, platform) in platforms.enumerated() {
            if index < platforms.count - 1 {
                platformString += platform.name + ", "
            } else {
                platformString += platform.name
            }
            
            
        }
        self.platformsLabel.text = platformString
    }
    
    
    
    
    
    
    
    
    
    
    //MARK: parseHTML
    
    func parseHTML(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            
            
            for streamContainer in doc.css(".listcell") {
                var viewers: String?
                
                if let splitViewersArray = streamContainer.at_css(".text-muted")?.content?.split(separator: " ") {
                    viewers = "\(splitViewersArray[0]) \(splitViewersArray[1])"
                }
                let username = streamContainer.at_css(".username-light")
                let weblink = streamContainer.at_css("a")
                let imageLink = streamContainer.at_css(".stream-preview")
                let title = streamContainer.at_css("a[title]")?.text
                
                if weblink!["href"]! == "https://www.twitch.tv/speedrun" {
                    streams.append(Stream(title: String(describing: title!), viewers: String(describing: viewers!), username: String(describing: "Speedrun"), imageLink: String(describing: imageLink!["src"]!), weblink: String(describing: weblink!["href"]!)))
                } else {
                    streams.append(Stream(title: String(describing: title!), viewers: String(describing: viewers!), username: String(describing: username!.content!), imageLink: String(describing: imageLink!["src"]!), weblink: String(describing: weblink!["href"]!)))

                }
            }
        }
    }
    
    
    
    
    
    
    
    
    //MARK: getStreams
    
    func getStreams(string: String) {
        if string != "" {
            let headers : HTTPHeaders = ["Content-Type": "text/html; charset=UTF-8"]
            var parameters = [String: Any]()
            
            parameters["game"] = string
            parameters["haspb"] = "no"
            parameters["following"] = "no"
            parameters["start"] = 0

            Alamofire.request("https://www.speedrun.com/ajax_streams.php", parameters: parameters, encoding: URLEncoding.default, headers: headers).responseString { response in
                
                print("\(response.result.isSuccess)")
                
                if let html = response.result.value {
                    self.parseHTML(html: html)
                    if self.streams.count > 0 {
                        self.streamsButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    

    
    
    
    
    
    
    
    
    
    //MARK: getSeriesName
    func getSeriesName(seriesUrl: String) {
        print("Here")
        
            guard let url = URL(string: seriesUrl) else { return }
            
            let dataRequest = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                
                guard let data = data else { return }
                let seriesData = try? JSONDecoder().decode(GameSeriesResponse.self, from: data)
                DispatchQueue.main.async {
                    self.seriesNameLabel.text = seriesData?.data.names.international
                }
            }
            dataRequest.resume()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameInfoView: UIView!
    @IBOutlet weak var streamsButton: UIButton!
    
    
    
    //MARK: streamsButtonPressed
    
    @IBAction func streamsButtonPressed(_ sender: Any) {
        let streamsCollectionView = self.storyboard?.instantiateViewController(withIdentifier: "StreamsView") as? StreamsCollectionViewController
        streamsCollectionView?.streams = streams
//        streamsCollectionView?.gameUrlName = stringArray[4]
        streamsCollectionView?.backgroundURL = game?.assets.background?.uri
        self.navigationController?.pushViewController(streamsCollectionView!, animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: favoriteButtonTapped
    @objc func favoriteButtonTapped() {
        FavoritesManager.shared.favorites.append(game!)
        print("Got here.")
        navigationItem.rightBarButtonItem? = UIBarButtonItem(customView: unfavoriteButton)

    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: unfavoriteButtonTapped
    
    @objc func unfavoriteButtonTapped() {
        print("Got There")
        
        for (index, favorite) in FavoritesManager.shared.favorites.enumerated() {
            if game?.id == favorite.id {
                FavoritesManager.shared.favorites.remove(at: index)
            }
        }
        navigationItem.rightBarButtonItem? = UIBarButtonItem(customView: favoriteButton)

        
    }
    
    
    
    
    
    
    
    //MARK: setVariables
    func setVariables(variables: [Variable], indexPath: IndexPath) {
        let category = categories[indexPath.row]
        let variablesViewController = storyboard?.instantiateViewController(withIdentifier: "VariablesView") as! VariablesTableViewController
        var displayVariables = [ResultVariable]()
        variablesViewController.variables = variables
        for variable in variables {
            if variable.isSubcategory == true {
                
                var choices = [Choices]()
                var keys = [String]()
                for key in variable.values.values.keys {

                    keys.append("var-\(variable.id)=\(key)")
                    choices.append(variable.values.values[key]!)
                }
                variablesViewController.keysForChoices.append(keys)
                variablesViewController.choices.append(choices)
                displayVariables.append(ResultVariable(name: variable.name, choices: choices))
                
                
                
            }
            
        }
        
        if displayVariables.count == 0 {
            
            let leaderboardController = self.storyboard?.instantiateViewController(withIdentifier: "LeaderboardsView") as! LeaderboardsTableViewController
            leaderboardController.leaderboardUrlString = "http://speedrun.com/api/v1/leaderboards/\(self.game!.id)/category/\(category.id)?embed=players"
            leaderboardController.game = self.game
            leaderboardController.category = self.categories[indexPath.row]
            self.navigationController?.pushViewController(leaderboardController, animated: true)
            
        } else {
            variablesViewController.category = self.categories[indexPath.row]
            variablesViewController.gameId = self.game?.id
            variablesViewController.game = self.game
            variablesViewController.displayVariables = displayVariables
            self.navigationController?.pushViewController(variablesViewController, animated: true)
        }
    }
    
    


    
    
    
    @IBOutlet weak var seriesNameLabel: UILabel!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var platformsLabel: UILabel!
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    

    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Categories"
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        var variableUrl = ""
        
        
        for item in category.links {
            if item.rel == "variables" {
                variableUrl = item.uri
                print(item.uri)
            }
            if item.rel == "leaderboard" {
                print(category.name)
            }
        }
        
        
        APIManager.sharedInstance.getVariables(variableUrlString: variableUrl, completion: {
            result in
            
            
            switch result {
            case .success(let data):
                do {
                    let variableData = try JSONDecoder().decode(VariablesResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.setVariables(variables: variableData.data, indexPath: indexPath)
                    }
                } catch {
                    
                }
            case .failure(let error):
                print(error)
            }
        })

    }
    

    
}
