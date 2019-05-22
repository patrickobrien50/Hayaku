//
//  SeriesViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 4/30/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit

class SeriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var series: ResultsSeries?
    var seriesName: String?
    var games = [ResultsGame]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = seriesName
        seriesTableView.delegate = self
        seriesTableView.dataSource = self
        

        // Do any additional setup after loading the view.
        
        if let url = URL(string: (series?.assets.coverLarge.uri)!) {
            self.seriesImageView.kf.setImage(with: url)
            self.seriesImageView.frame = CGRect(x: 0, y: 0, width: (series?.assets.coverLarge.width)!
                , height:  (series?.assets.coverLarge.height)!)
            
        }
            
        guard let url = URL(string: "http://www.speedrun.com/api/v1/series/" + series!.id + "/games")    else { return }
        print(url)
        let dataRequest = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            let gamesData = try? JSONDecoder().decode(ResultsGameResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.games = gamesData?.data ?? []
                self.seriesTableView.reloadData()
                self.animateTableViewCells()

            }
        }
        dataRequest.resume()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var seriesImageView: UIImageView!
    @IBOutlet weak var seriesTableView: UITableView!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.seriesTableView.rowHeight = 95
        let cell = seriesTableView.dequeueReusableCell(withIdentifier: "SeriesGameCell", for: indexPath) as! SeriesTableViewCell
        let imageSize = cell.imageView!.bounds.size.applying(CGAffineTransform(scaleX: self.traitCollection.displayScale, y: self.traitCollection.displayScale))
        cell.seriesTableViewCellLabel.text = games[indexPath.row].names.international
        let url = URL(string: games[indexPath.row].assets.cover(for: imageSize)!.uri)
        cell.seriesTableViewCellImageView.kf.setImage(with: url)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameView") as? GameViewController
        gameViewController?.gameId = games[indexPath.row].id
        gameViewController?.seriesName = seriesName
        self.navigationController?.pushViewController(gameViewController!, animated: true)
    }
    
    
    func animateTableViewCells() {
        let cells = seriesTableView.visibleCells as! [SeriesTableViewCell]
        let delayFactor: Double = 0.05
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: seriesTableView.rowHeight)
            let indexPath = seriesTableView.indexPath(for: cell)
            
            UIView.animate(
                withDuration: 1.0,
                delay: delayFactor * Double(indexPath!.row),
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
}
