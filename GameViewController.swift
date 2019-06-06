//
//  GameViewController.swift
//  Hayaku
//
//  Created by Patrick O'Brien on 10/2/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.
//

import UIKit
import Siesta


class GameViewController: UITableViewController, ResourceObserver {
    
    
    
    var seriesId: String?
    var gameName : String?
    var gameId : String?
    var game : Game?
    var seriesName : String?
    var categories = [Category]()
    var favorites: [Game] {
        
        get {
            if let favoriteStuff = UserDefaults.standard.data(forKey: "favorites") {
                if let favoritesData = try? JSONDecoder().decode([Game].self, from: favoriteStuff) {
                    let favoriteGames = favoritesData
                    return favoriteGames
                }
            }
            return []
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: "favorites")
            } catch {
                NSLog("Error saving favorites: \(error)")
            }
        }
    }

    func animateGameViewStuff() {
        UIView.animate(withDuration: 1.0, animations: {
            self.gameImageView.alpha = 1
            self.seriesNameLabel.alpha = 1
            self.releasedLabel.alpha = 1
            self.platformsLabel.alpha = 1
        })
    }
    
    let testView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
 
        
        gameImageView.alpha = 0
        seriesNameLabel.alpha = 0
        releasedLabel.alpha = 0
        platformsLabel.alpha = 0

        
        
        let favorite = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(favoriteButtonTapped))
        self.navigationItem.rightBarButtonItem = favorite
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        
        seriesNameLabel.textColor = UIColor(red: 120/255, green: 0/255, blue: 237/255, alpha: 1.0)
        
        
        
        if game == nil && gameName == nil {
            
            // If coming from SearchViewController or SeriesViewController.
            let gameUrl = "http://www.speedrun.com/api/v1/games/" + gameId! + "?embed=categories,variables,platforms"
            guard let url = URL(string: gameUrl) else { return }
            
            
            let dataRequest = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                let gamesData = try? JSONDecoder().decode(GamesResponse.self, from: data)
                let variablesData = try? JSONDecoder().decode(VariablesResponse.self, from: data)
                DispatchQueue.main.async {
                    self.game = gamesData?.data
                    self.game?.variables = variablesData
                    self.title = gamesData?.data.names.international
                    if let game = gamesData?.data {
                        self.getSeriesName(seriesUrl: String(describing: game.links[6].uri))
                        for category in game.categories!.data {
                            for link in category.links {
                                if link.rel == "leaderboard" {
                                    self.categories.append(category)

                                }
                            }
                        }
                        self.tableView.reloadData()
//                        self.testView.frame.size.height = CGFloat(game.assets.coverLarge.height)
//                        print(game.assets.coverLarge.height)
//                        self.testView.frame.size.width = CGFloat(game.assets.coverLarge.width)
//                        print(game.assets.coverLarge.width)
                        self.testView.layer.backgroundColor = UIColor.black.cgColor
                        self.testView.frame.origin = self.seriesNameLabel.frame.origin
                    }


                    //                let imageSize = self.gameImageView!.bounds.size.applying(CGAffineTransform(scaleX: self.traitCollection.displayScale, y: self.traitCollection.displayScale))
                    // Do any additional setup after loading the view.
                    
                    if let url = URL(string: (gamesData?.data.assets.coverMedium.uri)!) {
                        self.gameImageView.kf.setImage(with: url)
                        self.gameImageView.layer.shadowColor = UIColor.black.cgColor
                        self.gameImageView.layer.shadowOpacity = 1
                        self.gameImageView.layer.shadowOffset = CGSize(width: 3, height: -3)
                    }
                    
                    
                    self.seriesNameLabel.text = self.seriesName
                    if let  releaseDateArray = gamesData?.data.releaseDate.components(separatedBy: "-") {
                        self.releasedLabel.text = releaseDateArray[0]
                    }
                    if let platforms = gamesData?.data.platforms?.data {
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
                    for favGame in self.favorites {
                        if gamesData?.data.id == favGame.id {
                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                        }
                    }
                    self.animateGameViewStuff()
                }
            }
            dataRequest.resume()
        } else if game != nil && gameName == nil {
            
            //If coming from the FavoritesCollectionViewController
            
            if let game = game {
                
                self.tableView.reloadData()
                self.title = game.names.international
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                if let url = URL(string: (game.assets.coverMedium.uri)) {
                    self.gameImageView.kf.setImage(with: url)
                    self.gameImageView.layer.shadowColor = UIColor.black.cgColor
                    self.gameImageView.layer.shadowOpacity = 1
                    self.gameImageView.layer.shadowOffset = CGSize(width: 3, height: -3)
                    
                }
                
                getSeriesName(seriesUrl: game.links[6].uri)
                let releaseDateArray = game.releaseDate.components(separatedBy: "-")
                self.releasedLabel.text = releaseDateArray[0]
                for category in game.categories!.data {
                    for link in category.links {
                        if link.rel == "leaderboard" {
                            self.categories.append(category)
                            
                        }
                    }
                }
                if let platforms = game.platforms?.data {
                    
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
                
            }
            self.animateGameViewStuff()

        } else {
            
            //If coming from the PopularGamesCollectionViewController
            let gameUrl = "http://www.speedrun.com/api/v1/games?name=" + gameName!.replacingOccurrences(of: " ", with: "%20") + "&embed=categories,variables,platforms&max=1"
            guard let url = URL(string: gameUrl) else { return }
            
            print(url)
            
            let dataRequest = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                let gamesData = try? JSONDecoder().decode(PopularGamesResponse.self, from: data)
                DispatchQueue.main.async {
                    if let game = gamesData?.data[0] {
                        self.game = game
                        for category in game.categories!.data {
                            for link in category.links {
                                if link.rel == "leaderboard" {
                                    self.categories.append(category)
                                    
                                }
                            }
                        }
                        print(self.categories)
                        self.tableView.reloadData()


                    }
                    
                    self.getSeriesName(seriesUrl: String(describing: gamesData!.data[0].links[6].uri))
                    self.title = gamesData?.data[0].names.international

                    
                    if let url = URL(string: (gamesData?.data[0].assets.coverMedium.uri)!) {
                        self.gameImageView.kf.setImage(with: url)
                        self.gameImageView.layer.shadowColor = UIColor.black.cgColor
                        self.gameImageView.layer.shadowOpacity = 1
                        self.gameImageView.layer.shadowOffset = CGSize(width: 3, height: -3)
                    }
                    
                    
                    self.seriesNameLabel.text = self.seriesName
                    if let  releaseDateArray = gamesData?.data[0].releaseDate.components(separatedBy: "-") {
                        self.releasedLabel.text = releaseDateArray[0]
                    }
                    for category in (gamesData?.data[0].categories?.data)! {
                        for link in category.links {
                            if link.rel == "leaderboard" {
                                self.categories.append(category)
                                
                            }
                        }
                    }
                    if let platforms = gamesData?.data[0].platforms?.data {
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
                    for favGame in self.favorites {
                        if gamesData?.data[0].id == favGame.id {
                            print("Game Found")
                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                        }
                    }
                    self.animateGameViewStuff()
                }
            }
            dataRequest.resume()
            
        }
        
        
        
       
    }

    
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
    

    @IBAction func streamsButtonPressed(_ sender: Any) {
        let streamsCollectionView = self.storyboard?.instantiateViewController(withIdentifier: "StreamsView") as? StreamsCollectionViewController

        let urlString = game!.assets.coverSmall.uri
        let stringArray = urlString.components(separatedBy: "/")
        streamsCollectionView?.gameUrlName = stringArray[4]
        streamsCollectionView?.backgroundURL = game?.assets.background?.uri
        self.navigationController?.pushViewController(streamsCollectionView!, animated: true)
    }
    

    
    
    @objc func favoriteButtonTapped() {
        favorites.append(game!)
        print("Got here.")
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    
    }
    
    
    
    
    
    
    
//    func setPlatformIcons(platforms: [String]) {
//        let xbox = ["Xbox, Xbox 360, Xbox 360 Arcade,  Xbox One, Xbox One S, Xbox One X,"].split(separator: ", ")
//        let playstation = ["Playstation, Playstation 2, Playstation 3, Playstation 4, Playstation Classic, Playstation Now, Playstation Portable, Playstation Vita, Playstation TV"].split(separator: ", ")
//        let nintendo = ["Game Boy, Game Boy Advance, Game Boy Color, Game Boy Interface, GameCube, New Nintendo 3DS, Nintendo 3DS, Nintendo 64, Nintendo DS, Nintendo Entertainment System, SNES Classic Mini, Super Game Boy, Super Game Boy 2, Switch, Super Nintendo, Wii, Wii U, Wii U Virtual Console, Wii Virtual Console"].split(separator: ", ")
//        let windows = ["PC"]
//    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    
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
        return "Category"
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        let variablesViewController = storyboard?.instantiateViewController(withIdentifier: "VariablesView") as! VariablesTableViewController
        
        for item in category.links {
            if item.rel == "variables" {
                variablesViewController.variableURL = item.uri
                print(item.uri)
            }
            if item.rel == "leaderboard" {
                print(category.name)
            }
        }
        
    
        variablesViewController.gameId = game?.id
        variablesViewController.categoryId = self.categories[indexPath.row].id
        variablesViewController.game = self.game
        self.navigationController?.pushViewController(variablesViewController, animated: true)
        

    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
        
    }
    
}
