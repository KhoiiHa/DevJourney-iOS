//
//  ProjectsViewModelTests.swift
//  DevJourneyTests
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftData
import Testing
@testable import DevJourney

struct ProjectsViewModelTests {

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

}
