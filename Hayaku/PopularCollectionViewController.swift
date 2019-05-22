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


private let reuseIdentifier = "Cell"

class PopularCollectionViewController: UICollectionViewController {
    
    var imageUrls = [String]()
    var names = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Popular"
        self.view.layer.backgroundColor = UIColor.white.cgColor
        collectionView!.transform = CGAffineTransform(translationX: 0, y: collectionView!.frame.height)
        Alamofire.request("https://www.speedrun.com/ajax_gameslist.php").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseHTML(html: html)
                for cell in (self.collectionView?.visibleCells)! {
                    print(cell.bounds.height, cell.bounds.width)
                }
                self.collectionView?.reloadData()
                self.animateTableViewCells()
                print(self.imageUrls.count, self.names.count)

                
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func parseHTML(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            
            // #maincontainer .row #main .maincontent .panel #listingOptions
            for item in doc.css(".listcell div") {
                names.append(String(describing: item.text!))
            }
            for item in doc.css(".listcell a img") {
                self.imageUrls.append("https://www.speedrun.com" + String(describing: item["src"]!))
                var string = item.innerHTML
                
            }
        }
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
        return names.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCell", for: indexPath) as! PopularGameCollectionViewCell
        cell.popularGameImageView.kf.setImage(with: URL(string: imageUrls[indexPath.row]))
        cell.popularGameLabel.text = names[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameView") as? GameViewController
        gameViewController?.gameName = names[indexPath.row]
        gameViewController?.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationController?.pushViewController(gameViewController!, animated: true)
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

    
    func animateTableViewCells() {
                UIView.animate(
                    withDuration: 1.0, delay: 0.0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0.0,
                    options: [.curveEaseIn],
                    animations: {
                        self.collectionView!.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
    

    
}
