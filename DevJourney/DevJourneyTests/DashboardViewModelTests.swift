//
//  DashboardViewModelTests.swift
//  DevJourneyTests
//
//  Created by Vu Minh Khoi Ha on 21.07.26.
//

import Foundation
import Testing
@testable import DevJourney

struct DashboardViewModelTests {
    private let viewModel = DashboardViewModel()

    @Test func portfolioSummaryCountsReadyProjects() {
        let projects = [
            makePortfolioReadyProject(title: "DevJourney"),
            makePortfolioReadyProject(title: "ReadRhythm"),
            PortfolioProject(title: "SwipeBeats"),
        ]

        let summary = viewModel.portfolioSummary(for: projects)

        #expect(summary.readyProjectsCount == 2)
    }

    @Test func portfolioSummarySelectsProjectWithMostOpenActions() {
        let olderDate = Date(timeIntervalSince1970: 100)
        let smallerProject = PortfolioProject(
            title: "ReadRhythm",
            createdAt: olderDate
        )
        let attentionProject = PortfolioProject(
            title: "DevJourney",
            createdAt: olderDate.addingTimeInterval(100),
            milestones: [
                ProjectMilestone(title: "Dashboard ergänzen", sortOrder: 0),
                ProjectMilestone(title: "Screenshots erstellen", sortOrder: 1),
            ]
        )

        let summary = viewModel.portfolioSummary(
            for: [smallerProject, attentionProject]
        )

        #expect(summary.attentionProject === attentionProject)
        #expect(summary.attentionOpenActionCount == 8)
        #expect(summary.nextStepTitle == "Dashboard ergänzen")
    }

    @Test func portfolioSummaryUsesOldestProjectWhenAttentionIsEqual() {
        let olderProject = PortfolioProject(
            title: "ReadRhythm",
            createdAt: Date(timeIntervalSince1970: 100)
        )
        let newerProject = PortfolioProject(
            title: "DevJourney",
            createdAt: Date(timeIntervalSince1970: 200)
        )

        let summary = viewModel.portfolioSummary(
            for: [newerProject, olderProject]
        )

        #expect(summary.attentionProject === olderProject)
    }

    @Test func portfolioSummaryHandlesEmptyAndCompletedProjects() {
        let emptySummary = viewModel.portfolioSummary(for: [])

        #expect(emptySummary.readyProjectsCount == 0)
        #expect(emptySummary.attentionProject == nil)
        #expect(emptySummary.nextStepTitle == nil)

        let completedProject = makePortfolioReadyProject(title: "DevJourney")
        completedProject.milestones = [
            ProjectMilestone(title: "Release vorbereiten", isCompleted: true),
        ]

        let completedSummary = viewModel.portfolioSummary(for: [completedProject])

        #expect(completedSummary.readyProjectsCount == 1)
        #expect(completedSummary.attentionProject == nil)
        #expect(completedSummary.nextStepTitle == nil)
    }

    @Test func applicationFollowUpSummarySelectsEarliestDatedAction() {
        let undatedApplication = JobApplication(
            companyName: "Undatiert GmbH",
            positionTitle: "iOS Developer",
            nextAction: "Portfolio senden",
            createdAt: Date(timeIntervalSince1970: 50)
        )
        let laterApplication = JobApplication(
            companyName: "Later GmbH",
            positionTitle: "Swift Developer",
            nextAction: "Nachfassen",
            followUpAt: Date(timeIntervalSince1970: 300),
            createdAt: Date(timeIntervalSince1970: 100)
        )
        let nextApplication = JobApplication(
            companyName: "Next GmbH",
            positionTitle: "Junior Developer",
            nextAction: "Interview bestätigen",
            followUpAt: Date(timeIntervalSince1970: 200),
            createdAt: Date(timeIntervalSince1970: 150)
        )

        let summary = viewModel.applicationFollowUpSummary(
            for: [undatedApplication, laterApplication, nextApplication],
            on: Date(timeIntervalSince1970: 100)
        )

        #expect(summary.nextApplication === nextApplication)
        #expect(summary.nextActionTitle == "Interview bestätigen")
    }

    @Test func applicationFollowUpSummaryCountsDueActionsAndIgnoresEmptyOnes() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let referenceDate = Date(timeIntervalSince1970: 172_800)
        let overdueApplication = JobApplication(
            companyName: "Overdue GmbH",
            positionTitle: "iOS Developer",
            nextAction: "Nachfassen",
            followUpAt: referenceDate.addingTimeInterval(-86_400)
        )
        let dueTodayApplication = JobApplication(
            companyName: "Today GmbH",
            positionTitle: "Swift Developer",
            nextAction: "Unterlagen senden",
            followUpAt: referenceDate.addingTimeInterval(3_600)
        )
        let futureApplication = JobApplication(
            companyName: "Future GmbH",
            positionTitle: "Junior Developer",
            nextAction: "Interview bestätigen",
            followUpAt: referenceDate.addingTimeInterval(172_800)
        )
        let emptyApplication = JobApplication(
            companyName: "Empty GmbH",
            positionTitle: "Developer",
            nextAction: "  ",
            followUpAt: referenceDate
        )

        let summary = viewModel.applicationFollowUpSummary(
            for: [
                overdueApplication,
                dueTodayApplication,
                futureApplication,
                emptyApplication,
            ],
            on: referenceDate,
            calendar: calendar
        )

        #expect(summary.dueCount == 2)
        #expect(summary.nextApplication === overdueApplication)
    }

    @Test func applicationFollowUpSummaryHandlesApplicationsWithoutActions() {
        let application = JobApplication(
            companyName: "Example GmbH",
            positionTitle: "iOS Developer"
        )

        let summary = viewModel.applicationFollowUpSummary(for: [application])

        #expect(summary.dueCount == 0)
        #expect(summary.nextApplication == nil)
        #expect(summary.nextActionTitle == nil)
    }

    private func makePortfolioReadyProject(title: String) -> PortfolioProject {
        PortfolioProject(
            title: title,
            isAppStable: true,
            hasTests: true,
            hasReadme: true,
            hasScreenshots: true,
            hasAppIcon: true,
            hasDocumentation: true
        )
    }
}
