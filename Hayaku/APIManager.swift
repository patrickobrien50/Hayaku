//
//  APIManager.swift
//  
//
//  Created by Patrick O'brien on 11/15/19.
//

import UIKit
import Foundation
class APIManager  {
    
    
    static let sharedInstance = APIManager()

    let baseUrl = "http://www.speedrun.com/api/v1/"
    
    
    
    
    //MARK: getResultsGames
    
    
    func getResultsGames(searchText: String, completion: @escaping(Result<[ResultsGame], Error>) -> Void) {
        var gamesUrlComponents = URLComponents(string: baseUrl + "games")
        gamesUrlComponents?.queryItems = [URLQueryItem(name: "name", value: searchText), URLQueryItem(name: "max", value: "10")]
        guard let gamesUrl = gamesUrlComponents?.url else { return }
        print(gamesUrl)
        
        var gamesData : [ResultsGame]?

        let dataRequest = URLSession.shared.dataTask(with: gamesUrl) {
            (data, response, error) in
            
            guard let data = data else { return }
            do {
                let games = try JSONDecoder().decode(ResultsGameResponse.self, from: data)
                gamesData = games.data
                
            } catch let error {
                print(error)
            }

            if let resultsGames = gamesData {
                completion(.success(resultsGames))
            }
        }
        dataRequest.resume()
        
    }
    
    
    
    //MARK: getSeries
    
    
    func getResultsSeries(searchText: String, completion: @escaping(Result<[ResultsSeries], Error>) -> Void ) {
        var seriesData : [ResultsSeries]?
        var seriesUrlComponents = URLComponents(string: baseUrl + "series")
        seriesUrlComponents?.queryItems = [URLQueryItem(name: "name", value: searchText), URLQueryItem(name: "max", value: "10")]
        guard let seriesUrl = seriesUrlComponents?.url else { return }

        let dataRequest = URLSession.shared.dataTask(with: seriesUrl) {
            (data, response, error) in
            
            guard let data = data else { return }
            do {
                let series = try JSONDecoder().decode(ResultsSeriesResponse.self, from: data)
                seriesData = series.data
            } catch let error {
                print(error)
            }
                
            if let resultsSeries = seriesData {
                completion(.success(resultsSeries))
            }
            
        }
        dataRequest.resume()
    }
    
    //MARK: getUsers
    
    
    func getResultsUsers(searchText: String, completion: @escaping(Result<[ResultsUsers], Error>) -> Void) {
        var usersUrlComponents = URLComponents(string: baseUrl + "users")
        usersUrlComponents?.queryItems = [URLQueryItem(name: "name", value: searchText), URLQueryItem(name: "max", value: "1")]
        guard let usersUrl = usersUrlComponents?.url else { return }
        
        var usersData : [ResultsUsers]?

        let dataRequest = URLSession.shared.dataTask(with: usersUrl) {
            (data, response, error) in
            
            guard let data = data else { return }
            do {
                let users = try JSONDecoder().decode(ResultsUsersResponse.self, from: data)
                usersData = users.data
                
            } catch let error {
                print(error)
            }

            if let resultsUsers = usersData {
                completion(.success(resultsUsers))
            }
        }
        dataRequest.resume()
    }
    
    
    //MARK: getGameForGameView
    
    
    func getGameForGameView(gameInformation: String, popularController: Bool, completion: @escaping(Result<Data, Error>) -> Void) {
        
        var gameUrl : URL?
    
        if popularController {
            var gameUrlComponents = URLComponents(string: baseUrl + "games")
            gameUrlComponents?.queryItems = [URLQueryItem(name: "name", value: gameInformation) , URLQueryItem(name: "embed", value: "categories,variables,platforms")]
            gameUrl = gameUrlComponents?.url
        }
        
        
        if !popularController {
            var gameUrlComponents = URLComponents(string: baseUrl + "games/" + gameInformation)
            gameUrlComponents?.queryItems = [URLQueryItem(name: "embed", value: "categories,variables,platforms")]
            gameUrl = gameUrlComponents?.url
        }
        
    
        
        let dataRequest = URLSession.shared.dataTask(with: gameUrl!) {
            (data, response, error) in
            guard let data = data else { return }
        
            completion(.success(data))
            print("APIManager" , data)
            
        }
        dataRequest.resume()
    }
    
    
    
    
    
    func getVariables(variableUrlString: String, completion: @escaping(Result<Data, Error>) -> Void) {
        
        
        
        guard let variableURL = URL(string: variableUrlString) else { return }
        let dataRequest = URLSession.shared.dataTask(with: variableURL) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            completion(.success(data))
            
        }
        dataRequest.resume()
    
        
        
    }
    
    
    
    //This is the bottom of the class.
}
