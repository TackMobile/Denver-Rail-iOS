//
//  denverrailUITests.swift
//  denverrailUITests
//
//  Created by Naomi Himley on 6/1/16.
//  Copyright © 2016 Tack Mobile. All rights reserved.
//

import XCTest

class denverrailUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testOpenThenCloseMap() {
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
    
    func testSearch () {
        //Tap to open Search
        app.buttons["Station Search Button"].tap()
        
        //Check number of rows is 53 for all 53 stations
        let tablesQuery = app.tables
        let count = tablesQuery.cells.count
        XCTAssert(count == 53)
        
        //Search for Union
        let searchTextField = app.textFields["Find a Station"]
        searchTextField.tap()
        searchTextField.typeText("Union")
        app.keyboards.buttons["Done"].tap()
        
        //Check there is only one result
        let searchTableQuery = app.tables
        let resultCount = searchTableQuery.cells.count
        XCTAssert(resultCount == 1)
        
        //Select Yale to dismiss search and check Yale was selected
        app.tables.staticTexts["Union "].tap()
        
        let stationNameQuery:XCUIElementQuery = app.descendantsMatchingType(.Any)
        let stationNameLabel = stationNameQuery.elementMatchingType(.Any, identifier:"Station Name Label")
        XCTAssertTrue(stationNameLabel.label == "Union Station")
    }
    
    func testNowButton () {
        //Get time test is being run
        let now:NSDate = NSDate()
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.timeZone = NSTimeZone.init(name:"US/Mountain")!
        let unitFlags: NSCalendarUnit = [ .Hour, .Minute]
        let nowComponents = calendar?.components(unitFlags, fromDate: now)
        
        var hour = nowComponents!.hour
        let isPM : Bool
        if hour > 12 {
            isPM = true
            hour -= 12
        } else if hour == 12 {
            isPM = true
        } else {
            isPM = false
        }
        let minute = nowComponents!.minute
        let minuteString : String
        if minute < 10 {
            minuteString = "0" + String(minute)
        } else {
            minuteString = String(minute)
        }
        let AMPMString = isPM ? "PM" : "AM"
        
        //Start test
        app.buttons["autoButton"].tap()
        
        //Make sure the picker appears
        app.buttons["Open Time Picker"].tap()
        let datePicker = app.pickers["Non Auto Time Picker"]
        XCTAssertNotNil(datePicker)
        
        //Mess up the picker
        app.pickerWheels.elementBoundByIndex(0).adjustToPickerWheelValue("Holiday")
        app.pickerWheels.elementBoundByIndex(1).adjustToPickerWheelValue("12")
        app.pickerWheels.elementBoundByIndex(2).adjustToPickerWheelValue("59")

        
        //Tap NOW, dismiss and then make sure the current times show up
        app.buttons["Now"].tap()
        app.buttons["Done"].tap()
        
        let constructedTimeString = String(hour) + ":" + minuteString + " " + AMPMString
        let label = app.staticTexts[constructedTimeString]
        let exists = NSPredicate(format: "exists == true")
        expectationForPredicate(exists, evaluatedWithObject: label, handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}
