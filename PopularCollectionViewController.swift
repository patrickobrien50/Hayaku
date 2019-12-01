//
//  PopularCollectionViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/9/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit
import Kanna
import Alamofire
import Siesta
import SafariServices


private let reuseIdentifier = "Cell"

class PopularCollectionViewController: UICollectionViewController, ResourceObserver, SFSafariViewControllerDelegate {
    
    var streams = [PopularStream]()
    var games = [PopularGame]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.prefersLargeTitles = true

        
        Alamofire.request("https://www.speedrun.com/ajax_streamslist.php").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                APIManager.sharedInstance.parseStreamsHTML(html: html, completion: {
                    result in
                    switch result {
                    case .success(let popularStreams):
                        self.streams = popularStreams
                    case .failure(let error):
                        print(error)
                    }
                })
                self.collectionView?.reloadData()
                
                
                
            }
        }
        
        
        Alamofire.request("https://www.speedrun.com/ajax_gameslist.php").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                APIManager.sharedInstance.parseGamesHTML(html: html, completion: {
                    result in
                    switch result {
                    case .success(let popularGames):
                        self.games = popularGames
                    case .failure(let error):
                        print(error)
                    }
                })
                self.collectionView?.reloadData()
                
                
                
            }
        }
        
        
        
        
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControl(_ sender: Any) {
        collectionView?.reloadData()
    }
    
    
    
    func parseStreamsHTML(html: String) -> Void {

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return games.count
        case 1:
            return streams.count
        default:
            break
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCell", for: indexPath) as! PopularGameCollectionViewCell
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.popularGameLabel.text = games[indexPath.row].name
            cell.popularGameImageView.kf.setImage(with: URL(string: games[indexPath.row].imageLink))
            cell.playerCountLabel.text = games[indexPath.row].playerCount
        case 1:
            cell.popularGameLabel.text = streams[indexPath.row].title
            cell.popularGameImageView.kf.setImage(with: URL(string: streams[indexPath.row].imageLink))
            cell.playerCountLabel.text = "\(streams[indexPath.row].viewers) \(String(describing: streams[indexPath.row].username))"
        default:
            break
        }
        cell.layer.cornerRadius = 10
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.masksToBounds = false
        cell.layer.shadowOpacity = 0.25
        cell.layer.shadowRadius = 10
        return cell

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameView") as? GameViewController
            gameViewController?.gameName = games[indexPath.row].name
            gameViewController?.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationController?.pushViewController(gameViewController!, animated: true)
        case 1:
            guard let url = URL(string: streams[indexPath.row].weblink) else { return }
            presentSafariVC(url: url) 
        default:
            break
        }

    }
    
    func presentSafariVC(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
    }

    
    func animateTableViewCells() {
                UIView.animate(
                    withDuration: 1.0,
                    animations: {
                        self.collectionView!.alpha = 1
                })
            }
    

    
}
