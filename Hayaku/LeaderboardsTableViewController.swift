//
//  LeaderboardsTableViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/21/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit
import Kingfisher

class LeaderboardsTableViewController: UITableViewController {
    
    var runs = [RunPosition]()
    var players = [Player]()
    var game: Game?
    var leaderboardUrlString: String?
    var loaded = false
    var runInformation = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 75
        
        
        guard let url = URL(string: leaderboardUrlString!) else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            let leaderboardsData = try? JSONDecoder().decode(LeaderboardsResponse.self, from: data)
            
            DispatchQueue.main.async {
                if let leaderboards = leaderboardsData?.data {
                    self.players = leaderboards.players!.data
                    self.runs = leaderboards.runs
                    
                }
                
                self.tableView.reloadData()
            }
        }
        dataTask.resume()
        
        
        
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return players.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! RunTableViewCell
        

        
        cell.runnerNameLabel.text = players[indexPath.row].names?.international
        cell.runTimeLabel.text = runs[indexPath.row].run.times.primary.replacingOccurrences(of: "PT", with: "").lowercased()
        cell.runPositionLabel.text = String(describing: runs[indexPath.row].place)
        
        if players[indexPath.row].rel == "guest" {
            cell.runnerNameLabel.text = players[indexPath.row].name
        }
        
        if indexPath.row == 0 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy1st.uri))
            //rgb(255,215,0)
            cell.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
        } else if indexPath.row == 1 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy2nd.uri))
            cell.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        } else if indexPath.row == 2 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy3rd.uri))
            cell.backgroundColor = UIColor(red: 205/255, green: 127/255, blue: 50/255, alpha: 1)
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
            cell.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
        } else if indexPath.row == 1 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy2nd.uri))
            cell.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        } else if indexPath.row == 2 {
            cell.trophyImageView.kf.setImage(with: URL(string: game!.assets.trophy3rd.uri))
            cell.backgroundColor = UIColor(red: 205/255, green: 127/255, blue: 50/255, alpha: 1)
            loaded = true
            
        }
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(runs[indexPath.row])
        let runViewController = storyboard?.instantiateViewController(withIdentifier: "RunView") as! RunViewController
        runViewController.runInformation = runInformation
        runViewController.run = runs[indexPath.row].run
        runViewController.player = players[indexPath.row]
        
        self.navigationController?.pushViewController(runViewController, animated: true)
    }

}
