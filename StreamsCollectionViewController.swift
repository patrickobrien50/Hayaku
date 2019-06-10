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
import SafariServices

private let reuseIdentifier = "Cell"

import Siesta


struct Stream {
    var title: String
    var viewers : String
    var username: String
    var imageLink: String
    var weblink: String
}

class StreamsCollectionViewController: UICollectionViewController, SFSafariViewControllerDelegate {
    
    
    var streams: [Stream] = []
    var gameUrlName : String?
    var streamImageUrls = [String]()
    var streamLinks = [String]()
    var streamHeaders = [String]()
    var viewerCount = [String]()
    var users = [String]()
    var backgroundURL : String? 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Streams"

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return streams.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var delay: Double = 0.15
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StreamCell", for: indexPath) as! StreamsCollectionViewCell
        cell.streamImageView.kf.setImage(with: URL(string: streams[indexPath.row].imageLink))
        cell.streamTitleLabel.text = streams[indexPath.row].title
        cell.viewerCountLabel.text = streams[indexPath.row].viewers
        cell.streamerLabel.text = streams[indexPath.row].username
        cell.layer.cornerRadius = 10.0


        return cell
    }


    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = URL(string: streams[indexPath.row].weblink) else { return }
        presentSafariVC(url: url)    }
    
    func presentSafariVC(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    

}

extension StreamsCollectionViewController : ResourceObserver {
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
    }
    
}
