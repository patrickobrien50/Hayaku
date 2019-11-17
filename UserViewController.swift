//
//  UserViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 10/22/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//


// Number of sections should equal the number of different games the user has submitted records for.
// The number of cells in each section should be equal to the number of records submitted to the specific game in the section.

/*
 Make an array storing each individual game for reference when populating the Sections. Make the Header of each section the title of the game. Then make a dictionary when looping through the list of runs, attaching each record to the game it belongs to for cleaner referencing and makinng sure there are no records accidentaly put in the wrong section. Each Cell should provide the time of the run, the place on the leaderboard and the date it was submitted. Artwork for each game should be besides the record it belongs to. Grab the variables link from each game and make the request to find the variables. Then match the keys and values for the categories so we can display more specific information about each record.
 */
import UIKit
import Kingfisher
import Alamofire


struct GamesAndRuns {
    var game : PersonalBestGame
    var runs : [User]
}

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user : ResultsUsers?
    var games = [PersonalBestGame]()
    var gamesAndRuns = [GamesAndRuns]()
    
    @IBOutlet weak var personalBestsTableView: UITableView!
    let ordinalNumberFormatter = NumberFormatter()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .always
        ordinalNumberFormatter.numberStyle = .ordinal
        personalBestsTableView.rowHeight = 135
        personalBestsTableView.dataSource = self
        personalBestsTableView.delegate = self
        getPersonalBests(userId: user!.id)

        navigationItem.title = user?.names.international
        // Do any additional setup after loading the view.
    }
    
    
    func getVariables() {
        var url : String?
        for (gamesIndex, game) in self.gamesAndRuns.enumerated() {
            var newRuns = game.runs
            for item in game.game.links {
                if item.rel == "variables" {
                    url = item.uri
                }
            }
            
            guard let variablesUrl = URL(string: url!) else { return }
            let variablesDataRequest = URLSession.shared.dataTask(with: variablesUrl) {
                (data, response, error) in
                guard let data = data else { return }
                let variablesData = try! JSONDecoder().decode(VariablesResponse.self, from: data)
                
                DispatchQueue.main.async {
                    
                    
                    /*
                     Loop through each run. then loop through each variable for the game of that run. Find each variable key/value pair and set the correct labels to the variableText property of the run object.
                     */
                    
                    if variablesData.data.count > 0 {
                        newRuns = newRuns.sorted(by: {$0.run.id > $1.run.id})
                        for (runIndex, run) in newRuns.enumerated() {
                            var variableText = ""
                            for variable in variablesData.data {
                                for key in variable.values.values.keys {
                                    if key == run.run.values![variable.id] {
                                        if variableText == "" {
                                            variableText = variable.values.values[key]!.label
                                        } else if variableText != "" {
                                            variableText = variableText + " " + variable.values.values[key]!.label
                                        }
                                    }
                                }
                            }
                            newRuns[runIndex].run.variablesText = variableText
                            self.gamesAndRuns[gamesIndex].runs[runIndex].run.variablesText = variableText
                        }
                    }
                    self.personalBestsTableView.reloadData()
                }
            }
            variablesDataRequest.resume()
        }
    }
    
    func getPersonalBests(userId : String) {
        guard let personalBestsUrl = URL(string: "http://speedrun.com/api/v1/users/\(userId)/personal-bests?embed=game,category")
            else { return }
        let dataRequest = URLSession.shared.dataTask(with: personalBestsUrl) {
            (data, response, error) in
            guard let data = data else { return }
            let personalBestData = try! JSONDecoder().decode(UserResponse.self, from: data)
            
            DispatchQueue.main.async {
            
                
                // Gets all the unique games the user has submitted records for.
                for personalBest in personalBestData.data {
                    
                    var duplicateFound = false
                    
                    if self.games.count == 0 {
                        self.games.append(personalBest.game!.data)
                    }
                    for pb in self.games {
                        if personalBest.game!.data.id == pb.id {
                            duplicateFound = true
                        }
                        
                    }
                    
                    if duplicateFound == false {
                        self.games.append(personalBest.game!.data)
                    }


                }
                
                // Matches the runs for each game to the games we put into an array and sorted.
                
                self.games = self.games.sorted(by: {$0.names.international < $1.names.international})

                for game in self.games {
                    
                    var runsForGame = [User]()
                    
                    for personalBest in personalBestData.data {
                        if personalBest.game?.data.id == game.id {
                            runsForGame.append(personalBest)
                        }
                    }
                    self.gamesAndRuns.append(GamesAndRuns(game: game, runs: runsForGame))
                }
                
                self.gamesAndRuns = self.gamesAndRuns.sorted(by: {$0.game.names.international < $1.game.names.international})
                
                
                self.getVariables()
                
                
                
                
            }
            
        }
        dataRequest.resume()

        
    }
    
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let postDate = dateFormatter.date(from: gamesAndRuns[indexPath.section].runs[indexPath.row].run.status!.verifiedDate!)
        dateFormatter.dateFormat = "MM-dd-YYYY"
        
        

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalBestCell", for: indexPath) as! PersonalBestTableViewCell
        if let url = URL(string:gamesAndRuns[indexPath.section].game.assets.coverLarge.uri) {
            cell.gameImageView.kf.setImage(with: url)
        }
        
        cell.subcategoriesLabel.text = gamesAndRuns[indexPath.section].runs[indexPath.row].run.variablesText
        cell.categoryNameLabel.text = "Date: " + dateFormatter.string(from: postDate!)
        cell.gameNameLabel.text = gamesAndRuns[indexPath.section].runs[indexPath.row].category?.data.name
        cell.placeLabel.text = ordinalNumberFormatter.string(from: NSNumber(value: gamesAndRuns[indexPath.section].runs[indexPath.row].place))
        cell.runTimeLabel.text = "Time: " + gamesAndRuns[indexPath.section].runs[indexPath.row].run.times.primary.replacingOccurrences(of: "PT", with: "").lowercased()
        return cell
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return games.count
    
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return games[section].names.international
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesAndRuns[section].runs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if gamesAndRuns[indexPath.section].runs.count > 0 {
            let runViewController = storyboard?.instantiateViewController(withIdentifier: "RunView") as! RunViewController
            runViewController.run = gamesAndRuns[indexPath.section].runs[indexPath.row].run
            runViewController.user = user
            runViewController.subcategories = gamesAndRuns[indexPath.section].runs[indexPath.row].run.variablesText
            runViewController.category = gamesAndRuns[indexPath.section].runs[indexPath.row].category?.data
            runViewController.player = gamesAndRuns[indexPath.section].runs[indexPath.row].run.players[0]
            runViewController.gameName = gamesAndRuns[indexPath.section].game.names.international
            runViewController.place = ordinalNumberFormatter.string(from: NSNumber(value: gamesAndRuns[indexPath.section].runs[indexPath.row].place))
            
            
            self.navigationController?.pushViewController(runViewController, animated: true)
        }

    }
    
    func getVariablesForGame(game: PersonalBestGame) {
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class PersonalBestTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var runTimeLabel: UILabel!
    @IBOutlet weak var subcategoriesLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    
    
}
