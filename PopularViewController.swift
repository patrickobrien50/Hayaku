//
//  PopularViewController.swift
//  Hayaku
//
//  Created by Patrick O'Brien on 5/20/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.
//


/* List of HTML elements to get Popular Games
 
 1. div class = resultListing
    div with no class.
    div class = listCell
    a
    div with no class / contains name of game to search for.

*/
import UIKit
import Kanna
import Alamofire


class PopularViewController: UIViewController {
    
    var imageUrls = [String]()
    var names = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request("https://www.speedrun.com/ajax_gameslist.php").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseHTML(html: html)
            }
        }
        
        


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func parseHTML(html: String) -> Void {
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            
            // #maincontainer .row #main .maincontent .panel #listingOptions
            for item in doc.css(".listcell div") {
                names.append(String(describing: item.text))
            }
            for item in doc.css(".listcell a") {
                var string = item.innerHTML
                string = string?.trimmingCharacters(in: CharacterSet(charactersIn: "<img class=\"cover-tall-128 border\" alt=\"\" src=\\"))
                let url = string?.split(separator: "\"")[0]
                if url != "wide-128 border" {
                    imageUrls.append("www.speedrun.com" + String(describing: url))

                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
