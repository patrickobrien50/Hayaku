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

class RunViewController: UIViewController, SFSafariViewControllerDelegate {
    
    private var twitchClientId = "tkcu7nhde15jr0qpw6yoy2lp57xkuz"
    
    
    var players : [Player]?
    var player : Player?
    var run : Run?
    var groupPlayers = false
    var groupString: String?
    var backgroundURL : String?


    @IBOutlet weak var runnerNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    
    override func viewDidLoad() {
        
        
        navigationController?.navigationBar.prefersLargeTitles = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        super.viewDidLoad()
        
        if groupPlayers {
            runnerNameLabel.text = groupString!
            runnerNameLabel.numberOfLines = (run?.players.count)!
            
        } else {
            if player?.rel == "guest" {
                runnerNameLabel.text = player?.name
            } else {
                runnerNameLabel.text = player?.names?.international
            }
        }
//        if let url = URL(string: backgroundURL ?? "") {
//            guard let data = try? Data(contentsOf: url) else { return }
//            view.backgroundColor = UIColor(patternImage: UIImage(data: data)!)
//        }
        
        thumbnailImageView.image = UIImage(named: "Close Button")
        thumbnailImageView.isUserInteractionEnabled = true
        thumbnailImageView.addGestureRecognizer(tapGestureRecognizer)
        timeLabel.text = String(describing: run!.times.primary).replacingOccurrences(of: "PT", with: "").lowercased()
        
        
        

        if let videoLink = run?.videos?.links![0].uri {
            if videoLink.contains("twitch") {
                var twitchLinkArray = videoLink.split(separator: "/")
                print(twitchLinkArray[twitchLinkArray.count - 1])
                
                let imageRequestLink = "https://api.twitch.tv/kraken/videos/\(twitchLinkArray[twitchLinkArray.count - 1])?client_id=\(twitchClientId)"
                
                guard let url = URL(string: imageRequestLink) else { return }
                
                let dataTask = URLSession.shared.dataTask(with: url) {
                    (data, respone, error) in
                    
                    guard let data = data else { return }
                    let twitchData = try? JSONDecoder().decode(TwitchResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        if let urlString = twitchData?.preview {
                            self.thumbnailImageView.kf.setImage(with: URL(string: urlString))

                        }
                    }
                    
                }
                dataTask.resume()
                print(imageRequestLink)
            } else if videoLink.contains("youtu.be") || videoLink.contains("youtube") {
                var youtubeLinkArray = [Substring]()
                var youtubeVideoId = ""
                
                youtubeLinkArray = videoLink.split(separator: "/")
                
                if youtubeLinkArray[1].contains("youtu.be") {
                    youtubeVideoId = String(describing: youtubeLinkArray[2])
                    youtubeVideoId = String(describing: youtubeVideoId.prefix(11))

                } else if youtubeLinkArray[1].contains("youtube") {
                    youtubeLinkArray = youtubeLinkArray[2].split(separator: "=")
                    youtubeVideoId = String(describing: youtubeLinkArray[1].prefix(11))
                    print(youtubeVideoId)

                }
                
                
                let youtubeImageLink = "https://img.youtube.com/vi/\(youtubeVideoId)/hqdefault.jpg"
                
                thumbnailImageView.kf.setImage(with: URL(string: youtubeImageLink))
            } else if videoLink.contains("puu.sh") {
                thumbnailImageView.image = UIImage(named: "Close Button")
                commentLabel.text = "Video Not Available"
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
