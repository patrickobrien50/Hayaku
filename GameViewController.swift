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


class GameViewController: UITableViewController, ResourceObserver {
    
    
    let favoriteButton = UIButton(type: .system)
    let unfavoriteButton = UIButton(type: .system)
    


    
    var streams = [Stream]()
    var seriesId: String?
    var gameName : String?
    var gameId : String?
    var game : Game?
    var seriesName : String?
    var categories = [Category]()
    var gamesResource: Resource? {
        didSet{
            oldValue?.removeObservers(ownedBy: self)
            oldValue?.cancelLoadIfUnobserved(afterDelay: 0.1)
            
            
            gamesResource?.addObserver(self)
                            .loadIfNeeded()
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
        
        
        favoriteButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        favoriteButton.imageView?.contentMode = .scaleAspectFit
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        
        
        unfavoriteButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
        unfavoriteButton.imageView?.contentMode = .scaleAspectFit
        unfavoriteButton.addTarget(self, action: #selector(unfavoriteButtonTapped), for: .touchUpInside)
        
        
        
        
        
        
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
            
            // If coming from SearchViewController or SeriesViewController.
            let gameUrl = "http://www.speedrun.com/api/v1/games/" + gameId! + "?embed=categories,variables,platforms"
            print(gameUrl)
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
                    
                    let urlString = self.game!.assets.coverSmall.uri
                    let stringArray = urlString.components(separatedBy: "/")
                    print(stringArray[4])
                    Alamofire.request("https://www.speedrun.com/" + stringArray[4] + "/streams").responseString { response in
                        print("\(response.result.isSuccess)")
                        if let html = response.result.value {
                            let parameterString = self.getParameters(html: html)
//                            self.getStreams(string: parameterString)
                            self.getStreams(string: stringArray[4])
                            
                        }
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
                    for favGame in FavoritesManager.shared.favorites {
                        if gamesData!.data.id == favGame.id {
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.unfavoriteButton)
                        }
                    }
                    self.animateGameViewStuff()
                }
            }
            dataRequest.resume()
            
            
            
            
            
            
            
            
            
            
            
            
            
        } else if game != nil && gameName == nil {
 
            
            
            
            
            
            
            
            
            
            
            
            //If coming from the FavoritesCollectionViewController
            
            if let game = game {
                
                
                let urlString = self.game!.assets.coverSmall.uri
                let stringArray = urlString.components(separatedBy: "/")
                
                Alamofire.request("https://www.speedrun.com/" + stringArray[4] + "/streams").responseString { response in
                    print("\(response.result.isSuccess)")
                    if let html = response.result.value {
                        let parameterString = self.getParameters(html: html)
//                        self.getStreams(string: parameterString)
                        self.getStreams(string: stringArray[4])

                        
                    }
                }
                
                self.tableView.reloadData()
                self.title = game.names.international

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
                
                for favGame in FavoritesManager.shared.favorites {
                    if game.id == favGame.id {
                        print("Game Found")
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.unfavoriteButton)
                    }
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
                        let urlString = self.game!.assets.coverSmall.uri
                        let stringArray = urlString.components(separatedBy: "/")
                        
                        Alamofire.request("https://www.speedrun.com/" + stringArray[4] + "/streams").responseString { response in
                            print("\(response.result.isSuccess)")
                            if let html = response.result.value {
                                let parameterString = self.getParameters(html: html)
                                self.getStreams(string: parameterString)
                                
                            }
                        }
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
                    for favGame in FavoritesManager.shared.favorites {
                        if gamesData?.data[0].id == favGame.id {
                            print("Game Found")
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.unfavoriteButton)
                        }
                    }
                    self.animateGameViewStuff()
                }
            }
            dataRequest.resume()
            
        }
        
        
        
       
    }
    
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
    
    func getParameters(html: String) -> String {
        var formString : String?
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            for item in doc.css(".maincontent .panel.panel-body script"){
                let testString = item.text!
                let stringArray = testString.components(separatedBy: "'")
                formString = stringArray[1]
            }
            // #maincontainer .row #main .maincontent .panel #listingOptions
            
        }
        return formString ?? ""
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
    @IBOutlet weak var streamsButton: UIButton!
    @IBAction func streamsButtonPressed(_ sender: Any) {
        let streamsCollectionView = self.storyboard?.instantiateViewController(withIdentifier: "StreamsView") as? StreamsCollectionViewController
        streamsCollectionView?.streams = streams
//        streamsCollectionView?.gameUrlName = stringArray[4]
        streamsCollectionView?.backgroundURL = game?.assets.background?.uri
        self.navigationController?.pushViewController(streamsCollectionView!, animated: true)
    }
    
    
    
    @objc func favoriteButtonTapped() {
        FavoritesManager.shared.favorites.append(game!)
        print("Got here.")
        navigationItem.rightBarButtonItem? = UIBarButtonItem(customView: unfavoriteButton)

    }
    
    
    @objc func unfavoriteButtonTapped() {
        print("Got There")
        
        for (index, favorite) in FavoritesManager.shared.favorites.enumerated() {
            if game?.id == favorite.id {
                FavoritesManager.shared.favorites.remove(at: index)
            }
        }
        navigationItem.rightBarButtonItem? = UIBarButtonItem(customView: favoriteButton)

        
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
        var variableURL = ""
        var displayVariables = [ResultVariable]()
        
        
        for item in category.links {
            if item.rel == "variables" {
                variableURL = item.uri
                print(item.uri)
            }
            if item.rel == "leaderboard" {
                print(category.name)
            }
        }
        
            guard let url = URL(string: variableURL) else { return }
            
            let dataTask = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                guard let data = data else { return }
                
                let variablesData = try? JSONDecoder().decode(VariablesResponse.self, from: data)
                DispatchQueue.main.async {
                    
                    if let variables = variablesData?.data {
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
                    }
                    
                    
                    if displayVariables.count == 0 {
        
                        let leaderboardController = self.storyboard?.instantiateViewController(withIdentifier: "LeaderboardsView") as! LeaderboardsTableViewController
                        leaderboardController.leaderboardUrlString = "http://speedrun.com/api/v1/leaderboards/\(self.game!.id)/category/\(category.id)?embed=players"
                        leaderboardController.game = self.game
                        self.navigationController?.pushViewController(leaderboardController, animated: true)
                        
                    } else {
                        variablesViewController.gameId = self.game?.id
                        variablesViewController.categoryId = self.categories[indexPath.row].id
                        variablesViewController.game = self.game
                        variablesViewController.displayVariables = displayVariables
                        self.navigationController?.pushViewController(variablesViewController, animated: true)
                    }
                    
                    
                    
                    
                    
                    
                }
                
            }
            dataTask.resume()
            
        


        

    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
        
    }
    
}
