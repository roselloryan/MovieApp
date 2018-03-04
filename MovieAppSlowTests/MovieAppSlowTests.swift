//
//  MovieAppSlowTests.swift
//  MovieAppSlowTests
//
//  Created by RYAN ROSELLO on 2/26/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import XCTest
@testable import MovieApp

class MovieAppSlowTests: XCTestCase {
    
    var tmdbApiClient: MAAPIClient!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        tmdbApiClient = MAAPIClient.shared
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        tmdbApiClient = nil
        
        super.tearDown()
    }
    
    func testGetGenres() {
        let promise = expectation(description: "Valid dict from TMDB genres call")
        
        tmdbApiClient.getGenreCategoriesFromTMDB { (errorString, responseDict) in
            if errorString != nil {
                XCTFail("Error: \(errorString!)")
            }
            else if let genreDict = responseDict {
                if genreDict.keys.count > 0 {
                    promise.fulfill()
                }
            }
            else {
                XCTFail("Error: unknown error in \(#function)")
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
