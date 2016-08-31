//
//  Car_ConnectUITests.swift
//  Car-ConnectUITests
//
//  Created by Matthew Dutton on 8/31/16.
//  Copyright © 2016 Matthew Dutton. All rights reserved.
//

import XCTest

class Car_ConnectUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        
        snapshot("Launch_Screen")
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        
        let app = XCUIApplication()
        app.buttons["Hybrid"].tap()
        app.buttons["Park Here"].tap()
        app.tabBars.buttons["Park Car"].tap()
        
        snapshot("Stored_Pin_Screen")
        
    }
    
}
