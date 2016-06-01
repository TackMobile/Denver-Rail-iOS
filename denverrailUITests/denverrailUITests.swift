//
//  denverrailUITests.swift
//  denverrailUITests
//
//  Created by Naomi Himley on 6/1/16.
//  Copyright © 2016 Tack Mobile. All rights reserved.
//

import XCTest

class denverrailUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testOpenThenCloseMap() {
        
        let app = XCUIApplication()
        app.buttons["mapButton"].tap()
        
        let webViewQuery:XCUIElementQuery = app.descendantsMatchingType(.Any)
        let pdfMapView = webViewQuery.elementMatchingType(.Any, identifier:"Map View")
        XCTAssertNotNil(pdfMapView)
        XCTAssertTrue(pdfMapView.hittable)
        
        //Close map and make sure table with Eastbound/Westbound is showing
        app.buttons["mapButton"].tap()
        let eastboundButton = app.buttons["South Or East Button"]
        XCTAssertTrue(eastboundButton.hittable)
    }
    
    func testAutoButton() {
        
        let app = XCUIApplication()
        let autobuttonButton = app.buttons["autoButton"]
        autobuttonButton.tap()
        
        //After tapping the auto button make sure the picker appears
        app.buttons["Open Time Picker"].tap()
        let datePicker = app.pickers["Non Auto Time Picker"]
        XCTAssertNotNil(datePicker)
        
        //Set picker to Holiday then dismiss
        app.pickerWheels.elementBoundByIndex(0).adjustToPickerWheelValue("Holiday")
        app.buttons["Done"].tap()
        
        //Check that label showing Holiday exists
        let label = app.staticTexts["Holiday"]
        let exists = NSPredicate(format: "exists == true")
        
        expectationForPredicate(exists, evaluatedWithObject: label, handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}
