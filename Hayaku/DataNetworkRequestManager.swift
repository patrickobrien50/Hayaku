//
//  DataNetworkRequestManager.swift
//  Hayaku
//
//  Created by Patrick O'brien on 11/15/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import Foundation
import UIKit



class DataNetworkRequestManager {
    
    
    
    func getGames(url: URL) -> [ResultsGame] {
        var gamesData : [ResultsGame]?

        let dataRequest = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            do {
                let games = try JSONDecoder().decode(ResultsGameResponse.self, from: data)
                gamesData = games.data
            } catch let error {
                print(error)
            }
                
            
        }
        dataRequest.resume()
        
        if let resultsGames = gamesData {
            return resultsGames
        }
        return []
    }
    
    func getSeries(url: URL) -> [ResultsSeries] {
        var seriesData : [ResultsSeries]?

        let dataRequest = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            do {
                let series = try JSONDecoder().decode(ResultsSeriesResponse.self, from: data)
                seriesData = series.data
            } catch let error {
                print(error)
            }
                
            
        }
        dataRequest.resume()
        if let resultsSeries = seriesData {
            return resultsSeries
        }
        return []
    }
}
