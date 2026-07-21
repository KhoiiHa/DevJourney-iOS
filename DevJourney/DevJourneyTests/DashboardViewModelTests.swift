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
