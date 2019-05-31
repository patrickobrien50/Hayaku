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
    
    var player : Player?
    var run : Run?
    var backgroundURL : String?
    
    var runInformation: String?
    

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var runInformationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    
    override func viewDidLoad() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        super.viewDidLoad()
        thumbnailImageView.isUserInteractionEnabled = true
        thumbnailImageView.addGestureRecognizer(tapGestureRecognizer)
        commentLabel.text = run?.comment
        runInformationLabel.text = runInformation
        timeLabel.text = String(describing: run!.times.primary).replacingOccurrences(of: "PT", with: "").lowercased()
        if player?.rel == "guest" {
            self.title = player?.name
        } else {
            self.title = player?.names?.international
        }
        

        if let videoLink = run?.videos?.links![0].uri {
            if videoLink.contains("twitch") {
                var twitchLinkArray = videoLink.split(separator: "/")
                print(twitchLinkArray[twitchLinkArray.count - 1])
                
                let imageRequestLink = "https://api.twitch.tv/kraken/videos/\(twitchLinkArray[twitchLinkArray.count - 1])?client_id=\(twitchClientId)"
                
                guard let url = URL(string: imageRequestLink) else { return }
                
                let dataTask = URLSession.shared.dataTask(with: url) {
                    (data, respone, error) in
                    
                    guard let data = data else { return }
                    let twitchData = try! JSONDecoder().decode(TwitchResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.thumbnailImageView.kf.setImage(with: URL(string: twitchData.preview))
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
