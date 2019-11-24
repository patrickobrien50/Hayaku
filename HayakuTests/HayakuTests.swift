//
//  HayakuTests.swift
//  HayakuTests
//
//  Created by Patrick O'Brien on 5/20/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.
//  Use Given When Then method when creating tests to help separate the different elements of testing for easy reading.


import XCTest
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
        
        apiManager.getResultsGames(searchText: "Super Mario 64", completion: {
            result in
            
            switch result {
            case .success(let data):
                do {
                    let resultsGame = data
                    XCTAssertEqual("Super Mario 64", resultsGame[0].names.international)
                    
                } catch let error {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func testParsingHTML() {
        
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
