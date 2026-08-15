//
//  Car_ConnectUITests.swift
//  Car-ConnectUITests
//
//  Created by Matthew Dutton on 2/25/22.
//

import XCTest

final class Car_ConnectUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Launches the app with a bundled GPX route driving the LocationManager
    /// and verifies the full save → expand menu → clear → save parking-spot
    /// flow works through the floating action menu.
    func testParkingFlowWithSimulatedGPXRoute() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITEST_RESET"]
        app.launchEnvironment = ["UITEST_GPX": "ArchivesToEllipse"]
        app.launch()

        let saveButton = app.buttons["SaveParkingSpotButton"]
        let menuButton = app.buttons["ParkingMenuButton"]
        let clearButton = app.buttons["ClearParkingSpotButton"]

        XCTAssertTrue(saveButton.waitForExistence(timeout: 5),
                      "Save FAB should be visible on launch with no saved spot")

        // The mocked LocationManager publishes the first waypoint immediately,
        // but give it a retry window in case the ViewModel hasn't consumed it yet.
        let deadline = Date().addingTimeInterval(5)
        var didSave = false
        while Date() < deadline {
            saveButton.tap()
            if menuButton.waitForExistence(timeout: 1) {
                didSave = true
                break
            }
        }
        XCTAssertTrue(didSave,
                      "Tapping Save should transition the FAB to the menu state once a simulated location is available")

        // Expand the floating menu and tap Clear
        menuButton.tap()
        XCTAssertTrue(clearButton.waitForExistence(timeout: 2),
                      "Expanding the menu should reveal the Clear action")
        clearButton.tap()

        // After clearing, the FAB should return to its Save state
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3),
                      "Tapping Clear should return the FAB to Save state")
    }

    /// Verifies the two pin-focused features: the "Go to Pin" menu action is
    /// available once a spot is saved, and tapping the pin reveals a callout
    /// showing when the car was parked.
    func testGoToPinAndParkedTimestampCallout() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITEST_RESET"]
        app.launchEnvironment = ["UITEST_GPX": "ArchivesToEllipse"]
        app.launch()

        let saveButton = app.buttons["SaveParkingSpotButton"]
        let menuButton = app.buttons["ParkingMenuButton"]

        XCTAssertTrue(saveButton.waitForExistence(timeout: 5),
                      "Save FAB should be visible on launch with no saved spot")

        // Save a spot once a simulated location is available.
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            saveButton.tap()
            if menuButton.waitForExistence(timeout: 1) { break }
        }
        XCTAssertTrue(menuButton.exists, "Saving a spot should reveal the menu FAB")

        // Expand the menu and confirm the Go to Pin action is present, then tap it.
        menuButton.tap()
        let goToPinButton = app.buttons["GoToPinButton"]
        XCTAssertTrue(goToPinButton.waitForExistence(timeout: 2),
                      "Expanding the menu should reveal the Go to Pin action")
        goToPinButton.tap()

        // Tapping the pin should reveal the parked-timestamp callout.
        let pin = app.buttons["ParkingPin"]
        XCTAssertTrue(pin.waitForExistence(timeout: 3),
                      "The saved parking pin should be present on the map")
        pin.tap()
        let callout = app.descendants(matching: .any)["ParkingPinCallout"]
        XCTAssertTrue(callout.waitForExistence(timeout: 3),
                      "Tapping the pin should reveal the parked-timestamp callout")
    }

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
