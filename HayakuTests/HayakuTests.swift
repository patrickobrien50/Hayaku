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
        let expectation = XCTestExpectation(description: "Got the games")
                
        apiManager.getResultsGames(searchText: "Super Mario 64", completion: {
            result in
            print("Here")
            switch result {
            case .success(let data):
                resultsGames = data
                XCTAssertEqual("Super Mario 64", resultsGames![0].names.international)
                XCTAssertNotNil(data, "Did not get the Games")
            case .failure(let error):
                print(error)
            }
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)
    }
    
    func testParsingHTML() {
        let expectation = XCTestExpectation(description: "Parsing the HTML")
        Alamofire.request("https://www.speedrun.com/ajax_streamslist.php").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.apiManager.parseStreamsHTML(html: html, completion: {
                    result in
                    switch result {
                    case .success(let popularStreams):
                        let popularStream = popularStreams[0]
                        XCTAssertNotNil(popularStream)
                        break
                    case .failure(let error):
                        print(error)
                    }
                    expectation.fulfill()
                })
                
                
                
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    
    func testGetSeries() {
        var resultsSeries : [ResultsSeries]?
        
        let expectation = XCTestExpectation(description: "Got the Series")
        
        apiManager.getResultsSeries(searchText: "Super Mario", completion: {
            result in
            switch result {
            case .success(let data):
                resultsSeries = data
                XCTAssertNotNil(resultsSeries)
            case .failure(let error):
                print(error)
                
            }
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
