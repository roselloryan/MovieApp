//
//  MovieAppTests.swift
//  MovieAppTests
//
//  Created by RYAN ROSELLO on 2/15/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import XCTest
@testable import MovieApp

class MovieAppTests: XCTestCase {
    
    var movieVC: MAMoviesVC!
    var filterVC: MAFiltersTableVC!
    var dataStore: MADataStore!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        movieVC = storyboard.instantiateViewController(withIdentifier: Constants.Identifiers.MAMovieVCStoryboardIdentifier) as! MAMoviesVC
        
        //FilterTableVC
        filterVC = storyboard.instantiateViewController(withIdentifier: "FilterTableVC") as! MAFiltersTableVC
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        movieVC = nil
        super.tearDown()
    }
    
    func testMAMovieVCExistance() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssert(movieVC != nil, "movieVC nil")
        XCTAssert(movieVC.isKind(of: MAMoviesVC.self), "movieVC no of MAMoviesVC class ")
        
        
        XCTAssert(filterVC != nil, "filterVC is nil :(")
        XCTAssert(filterVC.isKind(of: MAFiltersTableVC.self), "MAFilterTableVC not of correct class")
        
        print(filterVC.tableView.numberOfSections)
        print(filterVC.tableView.numberOfRows(inSection: 0))
//        print(filterVC.tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
//        print(filterVC.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text)
//        let cell = filterVC.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MAFilterTableViewCell
//        print("cell.textLabel.text = \(cell.textLabel?.text ?? "nil text")")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
