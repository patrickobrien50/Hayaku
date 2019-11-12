//
//  RunViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/21/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit
import Kanna
import Kingfisher
import SafariServices
import Alamofire

class RunViewController: UIViewController, SFSafariViewControllerDelegate {
    
    private var twitchClientId = "tkcu7nhde15jr0qpw6yoy2lp57xkuz"
    
    
    var players : [Player]?
    var player : Player?
    var run : Run?
    var backgroundURL : String?
    var category : String?
    var subcategories : String?
    


    @IBOutlet weak var runnerNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var subcategoriesLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    override func viewDidLoad() {
        
        
        navigationController?.navigationBar.prefersLargeTitles = false
        super.viewDidLoad()
        

        if player?.rel == "guest" {
            runnerNameLabel.text = player?.name
        } else {
            runnerNameLabel.text = player?.names?.international
        }
        
//        if let url = URL(string: backgroundURL ?? "") {
//            guard let data = try? Data(contentsOf: url) else { return }
//            view.backgroundColor = UIColor(patternImage: UIImage(data: data)!)
//        }
        
        thumbnailImageView.image = UIImage(named: "Close Button")
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .black, scale: .default)
        let playButton = UIButton(frame: CGRect(x: thumbnailImageView.frame.midX, y: thumbnailImageView.frame.minY, width: 20, height: 20))
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        playButton.imageView?.contentMode = .scaleAspectFill
        playButton.addTarget(self, action: #selector(imageViewTapped), for: .touchUpInside)
        thumbnailImageView.addSubview(playButton)
        if let subcategoriesText = subcategories {
            subcategoriesLabel.text = subcategoriesText
        }
        if let categoryText = category {
            categoryLabel.text = categoryText
        }

        timeLabel.text = String(describing: run!.times.primary).replacingOccurrences(of: "PT", with: "").lowercased()
        
        
        

        if let videoLink = run?.videos?.links![0].uri {
            if videoLink.contains("twitch") {
                print(videoLink)
                let twitchLinkArray = videoLink.split(separator: "/")
                let headers : HTTPHeaders = ["Client-ID" : twitchClientId]
                
                Alamofire.request("https://api.twitch.tv/helix/videos?id=\(twitchLinkArray[twitchLinkArray.count - 1])", headers: headers).response {
                    response in
                    print(response)
                    guard let data = response.data else { return }
                    let twitchData = try! JSONDecoder().decode(TwitchResponse.self, from: data)
                    print(twitchData)
                    
                    self.thumbnailImageView.kf.setImage(with: URL(string: twitchData.data[0].thumbnailUrl.replacingOccurrences(of: "%{width}", with: "175").replacingOccurrences(of: "%{height}", with: "100")))
    
                    

                }

                
            } else if videoLink.contains("youtu.be") || videoLink.contains("youtube") {
                var youtubeLinkArray = [Substring]()
                var youtubeVideoId = ""
                
                youtubeLinkArray = videoLink.split(separator: "/")
                
                if youtubeLinkArray[1].contains("youtu.be") {
                    youtubeVideoId = String(describing: youtubeLinkArray[2])
                    youtubeVideoId = String(describing: youtubeVideoId.prefix(11))

                } else if youtubeLinkArray[1].contains("youtube") {
                    print(youtubeLinkArray)
                    youtubeLinkArray = youtubeLinkArray[2].split(separator: "=")
                    youtubeVideoId = String(describing: youtubeLinkArray[1].prefix(11))
                    print(youtubeVideoId)

                }
                
                
                let youtubeImageLink = "https://img.youtube.com/vi/\(youtubeVideoId)/hqdefault.jpg"
                
                thumbnailImageView.kf.setImage(with: URL(string: youtubeImageLink))
            } else if videoLink.contains("puu.sh") {
                thumbnailImageView.image = UIImage(named: "Close Button")
            }
        }

    }
    

    @objc func imageViewTapped(gesture: UITapGestureRecognizer) {
        guard let url = URL(string: run!.weblink) else { return }
        presentSafariVC(url: url)
    }
    

    func presentSafariVC(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
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
