//
//  VariablesTableViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/16/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit

struct ResultVariable {
    var name: String
    var choices : [Choices]
}

class VariablesTableViewController: UITableViewController {
    
    var leaderboardUrlString = "http://speedrun.com/api/v1/leaderboards/"
    var variableString = "?"
    var gameId: String?
    var category : Category?
    var variables = [Variable]()
    var variableURL: String?
    var keysForChoices = [[String]]()
    var choices = [[Choices]]()
    var game : Game?
    var displayVariables = [ResultVariable]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionHeaderHeight = 50

        self.title = "Subcategories"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let leaderboardsBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(leaderboardsButtonPressed))
        self.navigationItem.rightBarButtonItem = leaderboardsBarButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        


    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if displayVariables.count == 0 {
            return 1
        }
        return displayVariables.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if displayVariables.count == 0 {
            return 1
        }
        return displayVariables[section].choices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "VariableCell", for: indexPath)
        if indexPath.row == 0 {
            cell.accessoryType = .checkmark
        }

        cell.textLabel?.text = displayVariables[indexPath.section].choices[indexPath.row].label

        
        cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 18)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        if displayVariables.count == 0 {
            return "No options"
        }
        
        return displayVariables[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if displayVariables.count != 0 {
            if let tappedCell = tableView.cellForRow(at: indexPath) {
                let cells = tableView.visibleCells
                for cell in cells {
                    let cellIndexPath = tableView.indexPath(for: cell)
                    if cellIndexPath?.section == indexPath.section {
                        cell.accessoryType = .none
                    }
                    tappedCell.accessoryType = .checkmark
                }
                
            }
        }
    }
    
    
    @objc func leaderboardsButtonPressed() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let cells = tableView.visibleCells
        var runInformation = ""

        
        for cell in cells {
            if cell.accessoryType == .checkmark {
                if let indexPath = tableView.indexPath(for: cell) {
                    runInformation += "| \(choices[indexPath.section][indexPath.row].label) |"
                    variableString += "\(keysForChoices[indexPath.section][indexPath.row])&"
                    print(keysForChoices[indexPath.section][indexPath.row])
                    
                }
            }
        }
        
        APIManager.sharedInstance.getLeaderboards(gameId: game?.id ?? "", categoryId: category?.id ?? "", leaderboardComponents: variableString, completion: {
            result in

            switch result {
            case .success(let data):
                
                do {
                    let leaderboardsData = try JSONDecoder().decode(LeaderboardsResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        let leaderboardsView = self.storyboard?.instantiateViewController(withIdentifier: "LeaderboardsView") as! LeaderboardsTableViewController
                        leaderboardsView.leaderboards = leaderboardsData.data
                        leaderboardsView.runInformation = runInformation
                        leaderboardsView.game = self.game
                        if let categoryItem = self.category {
                            leaderboardsView.category = categoryItem
                        }
                        self.navigationController?.pushViewController(leaderboardsView, animated: true)
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }




                    
                } catch let error {
                    print(error)
                }
            case .failure(let error):
                print("APIManager \(error)")
                
            }
        })

    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
