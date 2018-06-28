//
//  GeoCrimesTests.swift
//  GeoCrimesTests
//
//  Created by Jovito Royeca on 28/06/2018.
//  Copyright © 2018 Jovito Royeca. All rights reserved.
//

import XCTest
import PromiseKit

@testable import GeoCrimes

class GeoCrimesTests: XCTestCase {
    
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAPI() {
        let expectation = XCTestExpectation(description: "testAPI()")
        
        let api = PoliceAPI()
        
        firstly {
            api.searchCrimes(onYear: 2017, onMonth: 2, atLatitude: kInitialLatitude, atlongitude: kInitialLongitude)
        }.done { (crimes: [Crime]?) in
            if let crimes = crimes {
                print("crimes = \(crimes)")
            } else {
                print("No data found.")
            }
            
            expectation.fulfill()
            
        }.catch { error in
            print("\(error)")
            CoreDataAPI.sharedInstance.deleteCrimes()
            expectation.fulfill()
        }
        
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
