//
//  DevJourneyUITests.swift
//  DevJourneyUITests
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import XCTest

final class DevJourneyUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCanCreateLearningGoal() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing")
        app.launch()

        app.staticTexts["Lernziele öffnen"].tap()

        XCTAssertTrue(app.navigationBars["Lernziele"].waitForExistence(timeout: 2))

        app.buttons["Lernziel hinzufügen"].tap()

        let titleField = app.textFields["Titel"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("SwiftUI UI-Test")

        app.buttons["Speichern"].tap()

        XCTAssertTrue(app.staticTexts["SwiftUI UI-Test"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
