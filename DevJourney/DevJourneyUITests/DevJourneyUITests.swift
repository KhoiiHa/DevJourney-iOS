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
    func testDashboardQuickLinksNavigateToCoreAreas() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing")
        app.launch()

        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 2))

        app.staticTexts["Lernziele öffnen"].tap()
        XCTAssertTrue(app.navigationBars["Lernziele"].waitForExistence(timeout: 2))
        app.navigationBars["Lernziele"].buttons.element(boundBy: 0).tap()

        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 2))

        app.staticTexts["Projekte öffnen"].tap()
        XCTAssertTrue(app.navigationBars["Projekte"].waitForExistence(timeout: 2))
        app.navigationBars["Projekte"].buttons.element(boundBy: 0).tap()

        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 2))

        app.staticTexts["Bewerbungen öffnen"].tap()
        XCTAssertTrue(app.navigationBars["Bewerbungen"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testProjectMilestonesDriveReadinessAndNextStep() throws {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .portrait
        app.launchArguments.append("--ui-testing")
        app.launch()

        app.staticTexts["Projekte öffnen"].tap()
        XCTAssertTrue(app.navigationBars["Projekte"].waitForExistence(timeout: 3))

        app.buttons["projects.add"].tap()

        let projectTitleField = app.textFields["project.create.title"]
        XCTAssertTrue(projectTitleField.waitForExistence(timeout: 2))
        projectTitleField.tap()
        projectTitleField.typeText("Portfolio UI-Test")
        app.buttons["project.create.save"].tap()

        let projectRow = app.buttons["project.row.Portfolio UI-Test"]
        XCTAssertTrue(projectRow.waitForExistence(timeout: 2))

        let rowReadiness = app.staticTexts[
            "project.row.readiness.Portfolio UI-Test"
        ]
        XCTAssertTrue(rowReadiness.waitForExistence(timeout: 2))
        XCTAssertEqual(rowReadiness.label, "0 von 6")

        let rowNextStep = app.staticTexts[
            "project.row.next-step.Portfolio UI-Test"
        ]
        XCTAssertTrue(rowNextStep.waitForExistence(timeout: 2))
        XCTAssertEqual(
            rowNextStep.label,
            "Als Nächstes: App funktioniert stabil"
        )

        let overviewScreenshot = XCTAttachment(screenshot: app.screenshot())
        overviewScreenshot.name = "Projektübersicht mit Readiness"
        overviewScreenshot.lifetime = .keepAlways
        add(overviewScreenshot)

        let projectFilter = app.segmentedControls["projects.filter"]
        XCTAssertTrue(projectFilter.waitForExistence(timeout: 2))
        projectFilter.buttons["Bereit"].tap()
        XCTAssertTrue(projectRow.waitForNonExistence(timeout: 2))
        XCTAssertTrue(
            app.staticTexts["Keine passenden Projekte"]
                .waitForExistence(timeout: 2)
        )

        projectFilter.buttons["Aufmerksamkeit"].tap()
        XCTAssertTrue(projectRow.waitForExistence(timeout: 2))

        projectRow.tap()
        XCTAssertTrue(app.navigationBars["Projekt"].waitForExistence(timeout: 2))

        addMilestone("README schreiben", in: app)
        addMilestone("Screenshots ergänzen", in: app)

        let reorderButton = app.buttons["project.milestone.reorder"]
        XCTAssertTrue(reorderButton.waitForExistence(timeout: 2))
        reorderButton.tap()

        let firstMilestone = app.staticTexts[
            "project.milestone.title.README schreiben"
        ]
        let secondMilestone = app.staticTexts[
            "project.milestone.title.Screenshots ergänzen"
        ]
        XCTAssertTrue(firstMilestone.exists)
        XCTAssertTrue(secondMilestone.exists)

        moveMilestone(secondMilestone, before: firstMilestone, in: app)
        reorderButton.tap()

        let stableAppToggle = app.switches["project.readiness.stableApp"]
        reveal(stableAppToggle, in: app)
        stableAppToggle.coordinate(
            withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)
        ).tap()
        XCTAssertTrue(
            stableAppToggle.waitForValue("1", timeout: 2),
            "Der Readiness-Schalter wurde nicht aktiviert."
        )

        let readinessProgress = app.staticTexts["project.readiness.progress"]
        XCTAssertTrue(readinessProgress.waitForLabel("1 von 6", timeout: 2))

        let nextStep = app.staticTexts["project.next-step"]
        XCTAssertTrue(nextStep.waitForExistence(timeout: 2))
        XCTAssertEqual(nextStep.label, "Als Nächstes: Screenshots ergänzen")
    }

    @MainActor
    func testApplicationNextActionAppearsOnDashboard() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing")
        app.launch()

        app.staticTexts["Bewerbungen öffnen"].tap()
        XCTAssertTrue(app.navigationBars["Bewerbungen"].waitForExistence(timeout: 2))

        app.buttons["applications.add"].tap()

        let companyField = app.textFields["application.create.company"]
        XCTAssertTrue(companyField.waitForExistence(timeout: 2))
        companyField.tap()
        companyField.typeText("Example GmbH")

        let positionField = app.textFields["application.create.position"]
        positionField.tap()
        positionField.typeText("Junior iOS Developer")

        let actionField = app.textFields["application.create.next-action"]
        reveal(actionField, in: app)
        actionField.tap()
        actionField.typeText("Nach Bewerbungsstatus fragen")

        app.buttons["application.create.save"].tap()

        let rowAction = app.staticTexts[
            "application.row.next-action.Example GmbH"
        ]
        XCTAssertTrue(rowAction.waitForExistence(timeout: 2))
        XCTAssertEqual(rowAction.label, "Nach Bewerbungsstatus fragen")

        app.navigationBars["Bewerbungen"].buttons.element(boundBy: 0).tap()

        let dashboardFollowUp = app.buttons["dashboard.application-follow-up"]
        XCTAssertTrue(dashboardFollowUp.waitForExistence(timeout: 2))
        XCTAssertTrue(
            dashboardFollowUp.label.contains("Nach Bewerbungsstatus fragen")
        )
        XCTAssertFalse(app.staticTexts["Fortschritt prüfen"].exists)

        let dashboardScreenshot = XCTAttachment(screenshot: app.screenshot())
        dashboardScreenshot.name = "Dashboard mit Bewerbungs-Fokus"
        dashboardScreenshot.lifetime = .keepAlways
        add(dashboardScreenshot)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    private func addMilestone(_ title: String, in app: XCUIApplication) {
        app.buttons["project.milestone.add"].tap()

        let alert = app.alerts["Meilenstein hinzufügen"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        let titleField = alert.textFields["Titel"]
        titleField.tap()
        titleField.typeText(title)
        alert.buttons["Speichern"].tap()
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<4 where !element.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(element.isHittable)
    }

    private func moveMilestone(
        _ milestone: XCUIElement,
        before destinationMilestone: XCUIElement,
        in app: XCUIApplication
    ) {
        for _ in 0..<2 where milestone.frame.minY > destinationMilestone.frame.minY {
            let sourceY = (milestone.frame.midY - app.frame.minY) / app.frame.height
            let destinationY = (
                destinationMilestone.frame.minY - app.frame.minY
            ) / app.frame.height
            let source = app.coordinate(
                withNormalizedOffset: CGVector(dx: 0.94, dy: sourceY)
            )
            let destination = app.coordinate(
                withNormalizedOffset: CGVector(dx: 0.94, dy: destinationY)
            )

            source.press(forDuration: 1, thenDragTo: destination)
        }

        XCTAssertLessThan(milestone.frame.minY, destinationMilestone.frame.minY)
    }
}

private extension XCUIElement {
    func waitForLabel(_ label: String, timeout: TimeInterval) -> Bool {
        waitFor(
            NSPredicate(format: "label == %@", label),
            timeout: timeout
        )
    }

    func waitForValue(_ value: String, timeout: TimeInterval) -> Bool {
        waitFor(
            NSPredicate(format: "value == %@", value),
            timeout: timeout
        )
    }

    private func waitFor(_ predicate: NSPredicate, timeout: TimeInterval) -> Bool {
        XCTWaiter.wait(
            for: [XCTNSPredicateExpectation(predicate: predicate, object: self)],
            timeout: timeout
        ) == .completed
    }
}
