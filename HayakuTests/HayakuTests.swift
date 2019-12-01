//
//  HayakuTests.swift
//  HayakuTests
//
//  Created by Patrick O'Brien on 5/20/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.
//  Use Given When Then method when creating tests to help separate the different elements of testing for easy reading.


import XCTest
import Alamofire
@testable import Hayaku

class HayakuTests: XCTestCase {
    
    let apiManager = APIManager()
    
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
  
    
    func testGetGames() {
        var resultsGames : [ResultsGame]?
                
        apiManager.getResultsGames(searchText: "Super Mario 64", completion: {
            result in
            print("Here")
            switch result {
            case .success(let data):
                resultsGames = data
            case .failure(let error):
                print(error)
            }
        })
        DispatchQueue.main.async {
            guard let resultsGame = resultsGames else { return }
            XCTAssertEqual("Donkey Kong", resultsGame[0].names.international)
        }

    }
    
    func testParsingHTML() {
        Alamofire.request("https://www.speedrun.com/ajax_streamslist.php").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.apiManager.parseStreamsHTML(html: html, completion: {
                    result in
                    switch result {
                    case .success(let popularStreams):
                        let popularStream = popularStreams[0]
                        break
                    case .failure(let error):
                        print(error)
                    }
                })
                
                
                
            }
        }
    }
    
    
    

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
