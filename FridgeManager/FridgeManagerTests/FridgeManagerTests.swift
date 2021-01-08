//
//  FridgeManagerTests.swift
//  FridgeManagerTests
//
//  Created by ChloeHuHu on 2020/11/25.
//

import XCTest
@testable import FridgeManager

class FridgeManagerTests: XCTestCase {
    
    var vc: FoodListViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let date = Date()
        vc = FoodListViewController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testIsExpired() {
        
        let theDayBeforeToday = vc.getExpiredFood(date: Date().addingTimeInterval(-99999))
        
        XCTAssertEqual(theDayBeforeToday, true)
    }
    
    func testNotExpired() {
        
        let tomorrow = vc.getExpiredFood(date: Date().addingTimeInterval(99999))
        
        XCTAssertEqual(tomorrow, false)
    }
    
    func testfail() {
        let fail = vc.getExpiredFood(date: Date().addingTimeInterval(99999))
        
        XCTAssertNotEqual(fail, true)
    }
}
