//
//  StreamsCollectionViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/10/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

private let reuseIdentifier = "Cell"

import Siesta


struct Stream {
    var title: String
    var viewers : String
    var username: String
    var imageLink: String
    var weblink: String
}

class StreamsCollectionViewController: UICollectionViewController {
    
    var gameUrlName : String?
    var streamImageUrls = [String]()
    var streamLinks = [String]()
    var streamHeaders = [String]()
    var viewerCount = [String]()
    var users = [String]()
    var backgroundURL : String? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let data = try? Data(contentsOf: URL(string: backgroundURL!)!) else { return }
        
        
        self.collectionView?.backgroundColor = UIColor(patternImage: UIImage(data: data)!)
        
        self.title = "Streams"
        Alamofire.request("https://www.speedrun.com/" + gameUrlName! + "/streams").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                let parameterString = self.getParameters(html: html)
                self.getStreams(string: parameterString)
   
                
                
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    func getParameters(html: String) -> String {
        var formString : String?
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            for item in doc.css(".maincontent .panel.panel-body script"){
                let testString = item.text!
                let stringArray = testString.components(separatedBy: "'")
                formString = stringArray[1]
                print(formString)
            }
            // #maincontainer .row #main .maincontent .panel #listingOptions

        }
        return formString ?? ""
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
        return streamImageUrls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var delay: Double = 0.15
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StreamCell", for: indexPath) as! StreamsCollectionViewCell
        cell.streamImageView.kf.setImage(with: URL(string: streamImageUrls[indexPath.row]))
        cell.streamTitleLabel.text = streamHeaders[indexPath.row]
        cell.viewerCountLabel.text = viewerCount[indexPath.row]
        cell.streamerLabel.text = users[indexPath.row]
        cell.layer.cornerRadius = 10.0
//        cell.transform = CGAffineTransform(translationX: 500.0, y: 0.0)


        return cell
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
    func parseHTML(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            
            for item in doc.css(".listcell .preview") {
                streamImageUrls.append(String(describing: item["src"]!))
            }
            
            for item in doc.css(".listcell > a") {
                streamLinks.append(String(describing: item["href"]!))
                streamHeaders.append(String(describing: item.text!))
            }
            
            for item in doc.css(".listcell div > .text-muted") {
                if let splitViewersAndStreamers = item.content?.split(separator: " ") {
                    viewerCount.append("\(splitViewersAndStreamers[0]) \(splitViewersAndStreamers[1] )")
                    users.append(String(splitViewersAndStreamers[2]))

                }
            }
            
            
        }
        print(users.count, viewerCount.count, streamLinks.count, streamHeaders.count, streamImageUrls.count)
    }

    
    func getStreams(string: String) {
        if string != "" {
            let headers : HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded; charset=UTF-8"]
            let separators = CharacterSet(charactersIn: "=&")
            var stringArray = string.components(separatedBy: separators)
            var index = 0
            var parameters = [String: Any]()
            
            while index < stringArray.count {
                parameters[stringArray[index]] = stringArray[index + 1]
                index += 2
            }
            parameters["pagelink"] = "/streams"
            parameters["pagesize"] = 1
            Alamofire.request("https://www.speedrun.com/ajax_streamslist.php", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseString { response in
                
                print("\(response.result.isSuccess)")
                
                if let html = response.result.value {
                    self.parseHTML(html: html)
                    self.collectionView?.reloadData()
                }
                
            }
        } else {
            streamImageUrls.append("https://placekitten.com/g/300/200")
            streamHeaders.append(" ¯\\_(ツ)_/¯ ")
            viewerCount.append("Looks like no one is streaming this game")
            users.append("")
            self.collectionView?.reloadData()
        }
    }
    
//    func animateCells() {
//        UIView.animate(withDuration: 0.75, delay: delay * Double(indexPath.row), animations: {
//            cell.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
//            cell.streamTitleLabel.alpha = 1
//            cell.streamImageView.alpha = 1
//            cell.viewerCountLabel.alpha = 1
//            cell.streamerLabel.alpha = 1
//        })
//    }
}

extension StreamsCollectionViewController : ResourceObserver {
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
    }
    
}
