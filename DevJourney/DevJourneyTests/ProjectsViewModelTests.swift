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
        #expect(viewModel.validationMessage == "Titel ist ein Pflichtfeld.")
        #expect(viewModel.newProjectStatus == PortfolioProjectStatus.planned)

        viewModel.newProjectTitle = "DevJourney"
        viewModel.newProjectGitHubURL = " https://github.com/example/devjourney "

        #expect(viewModel.canAddProject == true)
        #expect(viewModel.validationMessage == nil)
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

    @Test func projectDetailRequiresTitleAndSavesTrimmedValues() {
        let project = PortfolioProject(title: "DevJourney")
        let viewModel = ProjectDetailViewModel(project: project)

        viewModel.title = "  "

        #expect(viewModel.canSave == false)
        #expect(viewModel.validationMessage == "Titel ist ein Pflichtfeld.")

        viewModel.title = "  DevJourney iOS  "
        viewModel.summary = "  Lernziele, Projekte und Bewerbungen verwalten  "
        viewModel.githubURL = " https://github.com/example/devjourney "
        viewModel.notes = " SwiftUI und SwiftData MVP "
        viewModel.status = PortfolioProjectStatus.inProgress
        viewModel.save(to: project)

        #expect(project.title == "DevJourney iOS")
        #expect(project.summary == "Lernziele, Projekte und Bewerbungen verwalten")
        #expect(project.githubURL == "https://github.com/example/devjourney")
        #expect(project.notes == "SwiftUI und SwiftData MVP")
        #expect(project.status == PortfolioProjectStatus.inProgress)
        #expect(viewModel.validationMessage == nil)
    }

}
