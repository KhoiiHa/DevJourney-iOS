//
//  DevJourneyTests.swift
//  DevJourneyTests
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Testing
import SwiftData
@testable import DevJourney

struct DevJourneyTests {

    @Test func goalRequiresNonEmptyTitle() {
        let viewModel = GoalsViewModel()

        #expect(viewModel.canAddGoal == false)

        viewModel.newGoalTitle = "  SwiftUI lernen  "

        #expect(viewModel.canAddGoal == true)
    }

    @Test func projectUsesDefaultStatusAndRequiresTitle() {
        let viewModel = ProjectsViewModel()

        #expect(viewModel.canAddProject == false)
        #expect(viewModel.newProjectStatus == PortfolioProjectStatus.planned)

        viewModel.newProjectTitle = "DevJourney"
        viewModel.newProjectGitHubURL = " https://github.com/example/devjourney "

        #expect(viewModel.canAddProject == true)
    }

    @MainActor
    @Test func projectOptionalFieldsAreTrimmedWhenAdded() throws {
        let container = try ModelContainer(
            for: PortfolioProject.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = ProjectsViewModel()
        viewModel.newProjectTitle = "DevJourney"
        viewModel.newProjectGitHubURL = " https://github.com/example/devjourney "
        viewModel.newProjectNotes = " SwiftData persistence built "

        viewModel.addProject(using: container.mainContext)

        let projects = try container.mainContext.fetch(FetchDescriptor<PortfolioProject>())
        #expect(projects.first?.githubURL == "https://github.com/example/devjourney")
        #expect(projects.first?.notes == "SwiftData persistence built")
    }

    @Test func applicationUsesDefaultStatusAndRequiresCompanyAndPosition() {
        let viewModel = ApplicationsViewModel()

        #expect(viewModel.canAddApplication == false)
        #expect(viewModel.status == JobApplicationStatus.open)

        viewModel.companyName = "Apple"
        viewModel.positionTitle = "iOS Developer"

        #expect(viewModel.canAddApplication == true)
    }

    @MainActor
    @Test func applicationJobURLIsTrimmedWhenAdded() throws {
        let container = try ModelContainer(
            for: JobApplication.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = ApplicationsViewModel()
        viewModel.companyName = "Apple"
        viewModel.positionTitle = "iOS Developer"
        viewModel.jobURL = " https://jobs.apple.com/example "

        viewModel.addApplication(using: container.mainContext)

        let applications = try container.mainContext.fetch(FetchDescriptor<JobApplication>())
        #expect(applications.first?.jobURL == "https://jobs.apple.com/example")
    }

}
