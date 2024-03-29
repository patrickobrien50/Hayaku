//
//  LeaderboardsTableViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/21/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

/*
 Fix issue with Group Runs not showing the correct information in the leaderboard screen.
 When multiple players are part of the same run, implement logic that increases the size of the table view cell to accomodate the multiple lines on the label. Also increase the height of the label and number of lines based on how many players are in te run.
 Make sure it adjusts for anywhere from 2-10 people.
 */

import UIKit
import Kingfisher

class LeaderboardsTableViewController: UITableViewController {
    
    var runs = [RunPosition]()
    var players = [Player]()
    var groupRun = false
    var game: Game?
    var leaderboardUrlString: String?
    var loaded = false
    var runInformation = ""
    var groupStringArray = [String]()
    let ordinalNumberFormatter = NumberFormatter()
    var category : Category?
    var leaderboards : Leaderboards?
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ordinalNumberFormatter.numberStyle = .ordinal
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = "Leaderboards"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let leaderboards = leaderboards {
            self.players = leaderboards.players!.data
            self.runs = leaderboards.runs
            if self.runs.count > 0 {
                if self.runs[0].run.players.count > 1 {
                    self.getGroups(runs: leaderboards.runs, players: leaderboards.players!.data)
                    self.groupRun = true


                }
            }




        }
        self.tableView.reloadData()

    }
    /*
     
     1: Loop through the players.
     2: Use the run.players.count
     3: Keep track of the
     
     
     
     */
    func getGroups(runs: [RunPosition], players: [Player]) {
        
        for run in runs {
            var string = ""
            
            for runner in run.run.players {
                for player in players {
                    print(runner)
                    print(player)
        
                    if runner.id == nil {
                        string.append("\(runner.name!)  \n")
                        break
       
                    } else if runner.id == player.id {
                        if player.rel == "guest" {
                            string.append("\(String(describing: player.name!)) \n")
                            
                        } else {
                            string.append("\(String(describing: player.names!.international)) \n")
                        }
                        break

                    }
                }
            }
            
            groupStringArray.append(string)
        }
        print(runs)
       
 
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if runs.count == 0 {
            return 1
        }
        
        return runs.count
    }
    


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! RunTableViewCell
        
        if runs.count == 0 {
            cell.runTimeLabel.text = "No runs available"
            cell.runnerNameLabel.text = ""
            cell.runPositionLabel.text = ""
            cell.accessoryType = .none
            tableView.tableFooterView = UIView()
            return cell
        }
        
        cell.runTimeLabel.text = runs[indexPath.row].run.times.primary.replacingOccurrences(of: "PT", with: "").lowercased()
        cell.runPositionLabel.text = ordinalNumberFormatter.string(from: NSNumber(value: runs[indexPath.row].place))
        

        if !groupRun {
            if players[indexPath.row].rel == "guest" {
                cell.runnerNameLabel.text = players[indexPath.row].name
            } else {
                cell.runnerNameLabel.text = players[indexPath.row].names?.international

            }
        } else {
            print(groupStringArray)
            print(runs.count)
            cell.runnerNameLabel.lineBreakMode = .byWordWrapping
            cell.runnerNameLabel.numberOfLines = 0
            cell.runnerNameLabel.text = groupStringArray[indexPath.row]
            cell.runnerNameLabel.textAlignment = .right
        }
        
        

        
        if indexPath.row == 0 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy1st.uri))
            //rgb(255,215,0)
//            cell.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
        } else if indexPath.row == 1 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy2nd.uri))
//            cell.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        } else if indexPath.row == 2 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy3rd.uri))
//            cell.backgroundColor = UIColor(red: 205/255, green: 127/255, blue: 50/255, alpha: 1)
            loaded = true
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! RunTableViewCell
        cell.trophyImageView.kf.cancelDownloadTask()
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! RunTableViewCell
        if indexPath.row == 0 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy1st.uri))
            //rgb(255,215,0)
//            cell.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
        } else if indexPath.row == 1 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy2nd.uri))
//            cell.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        } else if indexPath.row == 2 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy3rd.uri))
//            cell.backgroundColor = UIColor(red: 205/255, green: 127/255, blue: 50/255, alpha: 1)
            loaded = true
            
        }
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if runs.count > 0 {
            let runViewController = storyboard?.instantiateViewController(withIdentifier: "RunView") as! RunViewController
            runViewController.run = runs[indexPath.row].run
            runViewController.category = category!
            runViewController.player = players[indexPath.row]
            runViewController.backgroundURL = game?.assets.background?.uri
            runViewController.gameName = game?.names.international
            runViewController.place = ordinalNumberFormatter.string(from: NSNumber(value: runs[indexPath.row].place))
            if groupRun {
                runViewController.groupString = groupStringArray[indexPath.row]
            }
            
            
            self.navigationController?.pushViewController(runViewController, animated: true)
        }

    }
    


}
