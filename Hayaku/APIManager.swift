//
//  APIManager.swift
//  
//
//  Created by Patrick O'brien on 11/15/19.
//

import UIKit
import Foundation
//class APIManager  {
//    
//
//    
//    
//    
//    func getGames(url: URL) {
//        var gamesData : [ResultsGame]?
//
//        let dataRequest = URLSession.shared.dataTask(with: url) {
//            (data, response, error) in
//            
//            guard let data = data else { return }
//            do {
//                let games = try JSONDecoder().decode(ResultsGameResponse.self, from: data)
//                gamesData = games.data
//            } catch let error {
//                print(error)
//            }
//            DispatchQueue.main.async {
//                if let resultsController = self.searchController.searchResultsController as? SearchResultsTableViewController {
//                    if let resultsGames = gamesData {
//                        resultsController.games = resultsGames
//                    }
//                }
//            }
//        }
//        dataRequest.resume()
//    }
//    
//    func getSeries(url: URL) -> [ResultsSeries] {
//        var seriesData : [ResultsSeries]?
//
//        let dataRequest = URLSession.shared.dataTask(with: url) {
//            (data, response, error) in
//            
//            guard let data = data else { return }
//            do {
//                let series = try JSONDecoder().decode(ResultsSeriesResponse.self, from: data)
//                seriesData = series.data
//            } catch let error {
//                print(error)
//            }
//                
//            
//        }
//        dataRequest.resume()
//        if let resultsSeries = seriesData {
//            return resultsSeries
//        }
//        return []
//    }
//}
