//
//  ProjectsViewModelTests.swift
//  DevJourneyTests
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
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

        try viewModel.addProject(using: container.mainContext)

        let projects = try container.mainContext.fetch(FetchDescriptor<PortfolioProject>())
        #expect(projects.first?.githubURL == "https://github.com/example/devjourney")
        #expect(projects.first?.notes == "SwiftData persistence built")
    }

    @Test func projectRequiresValidGitHubURLWhenProvided() {
        let viewModel = ProjectsViewModel()
        viewModel.newProjectTitle = "DevJourney"

        #expect(viewModel.canAddProject == true)

        viewModel.newProjectGitHubURL = "github.com/example/devjourney"

        #expect(viewModel.canAddProject == false)
        #expect(viewModel.validationMessage == "Bitte gib einen gültigen GitHub-Link ein.")

        viewModel.newProjectGitHubURL = "https://github.com/example/devjourney"

        #expect(viewModel.canAddProject == true)
        #expect(viewModel.validationMessage == nil)
    }

    @Test func projectRowSummarizesReadinessAndNextOpenStep() {
        let viewModel = ProjectsViewModel()
        let project = PortfolioProject(
            title: "DevJourney",
            isAppStable: true,
            hasTests: true,
            hasReadme: true
        )
        project.milestones = [
            ProjectMilestone(title: "Screenshots erstellen"),
        ]

        #expect(viewModel.readinessProgress(for: project) == 0.5)
        #expect(viewModel.readinessProgressText(for: project) == "3 von 6")
        #expect(
            viewModel.nextStepText(for: project) ==
                "Als Nächstes: Screenshots erstellen"
        )
        #expect(viewModel.hasOpenStep(for: project) == true)
    }

    @Test func projectRowRecognizesPortfolioReadyProject() {
        let viewModel = ProjectsViewModel()
        let project = makePortfolioReadyProject()

        #expect(viewModel.readinessProgress(for: project) == 1)
        #expect(viewModel.readinessProgressText(for: project) == "6 von 6")
        #expect(viewModel.nextStepText(for: project) == "Portfolio-bereit")
        #expect(viewModel.hasOpenStep(for: project) == false)
    }

    @Test func projectRowKeepsOpenMilestoneVisibleAfterReadinessIsComplete() {
        let viewModel = ProjectsViewModel()
        let project = makePortfolioReadyProject()
        project.milestones = [
            ProjectMilestone(title: "Case Study überarbeiten"),
        ]

        #expect(project.isPortfolioReady == true)
        #expect(viewModel.hasOpenStep(for: project) == true)
        #expect(
            viewModel.nextStepText(for: project) ==
                "Als Nächstes: Case Study überarbeiten"
        )
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

    @Test func projectDetailExposesOnlyValidWebURL() {
        let project = PortfolioProject(title: "DevJourney")
        let viewModel = ProjectDetailViewModel(project: project)

        viewModel.githubURL = "ftp://github.com/example/devjourney"

        #expect(viewModel.canSave == false)
        #expect(viewModel.validGitHubURL == nil)

        viewModel.githubURL = " https://github.com/example/devjourney "

        #expect(viewModel.canSave == true)
        #expect(viewModel.validGitHubURL?.absoluteString == "https://github.com/example/devjourney")
    }

    @Test func readinessProgressCountsCompletedRequirements() {
        let project = PortfolioProject(
            title: "DevJourney",
            isAppStable: true,
            hasTests: true,
            hasReadme: true
        )

        #expect(project.readinessCompletedCount == 3)
        #expect(project.readinessTotalCount == 6)
        #expect(project.readinessProgress == 0.5)
        #expect(project.isPortfolioReady == false)
    }

    @Test func projectIsPortfolioReadyWhenEveryRequirementIsCompleted() {
        let project = makePortfolioReadyProject()

        #expect(project.readinessCompletedCount == project.readinessTotalCount)
        #expect(project.readinessProgress == 1)
        #expect(project.isPortfolioReady == true)
    }

    @Test func nextOpenStepUsesFirstOrderedMilestoneBeforeReadiness() {
        let project = PortfolioProject(title: "DevJourney")
        let appStoreText = ProjectMilestone(
            title: "App Store Text vorbereiten",
            sortOrder: 2
        )
        let screenshots = ProjectMilestone(
            title: "Screenshots erstellen",
            sortOrder: 1
        )
        project.milestones = [
            appStoreText,
            ProjectMilestone(title: "MVP abschließen", isCompleted: true, sortOrder: 0),
            screenshots,
        ]

        #expect(project.nextOpenStepTitle == "Screenshots erstellen")

        screenshots.isCompleted = true
        appStoreText.isCompleted = true

        #expect(project.nextOpenStepTitle == "App funktioniert stabil")
    }

    @Test func completedProjectHasNoOpenStep() {
        let project = makePortfolioReadyProject()
        project.milestones = [
            ProjectMilestone(title: "MVP abschließen", isCompleted: true),
        ]

        #expect(project.nextOpenStepTitle == nil)
        #expect(project.openActionCount == 0)
    }

    @Test func projectWithoutMilestonesUsesSafeReadinessDefaults() {
        let project = PortfolioProject(title: "DevJourney")

        #expect(project.milestones.isEmpty)
        #expect(project.readinessCompletedCount == 0)
        #expect(project.readinessProgress == 0)
        #expect(project.isPortfolioReady == false)
        #expect(project.nextOpenStepTitle == "App funktioniert stabil")
        #expect(project.openActionCount == project.readinessTotalCount)
    }

    @MainActor
    @Test func milestoneEditorAddsAndRenamesTrimmedMilestone() throws {
        let container = try makeProjectContainer()
        let project = PortfolioProject(title: "DevJourney")
        container.mainContext.insert(project)
        let viewModel = ProjectDetailViewModel(project: project)

        viewModel.startAddingMilestone()
        viewModel.milestoneTitle = "  "
        #expect(viewModel.canSaveMilestone == false)

        viewModel.milestoneTitle = "  Screenshots erstellen  "
        try viewModel.saveMilestone(to: project, using: container.mainContext)

        let milestone = try #require(project.milestones.first)
        #expect(milestone.title == "Screenshots erstellen")
        #expect(milestone.sortOrder == 0)
        #expect(viewModel.isShowingMilestoneEditor == false)

        viewModel.startEditingMilestone(milestone)
        viewModel.milestoneTitle = "  App-Screenshots erstellen  "
        try viewModel.saveMilestone(to: project, using: container.mainContext)

        #expect(milestone.title == "App-Screenshots erstellen")
    }

    @MainActor
    @Test func projectDetailPersistsMilestoneAndReadinessChanges() throws {
        let container = try makeProjectContainer()
        let project = PortfolioProject(title: "DevJourney")
        let milestone = ProjectMilestone(title: "README schreiben")
        project.milestones.append(milestone)
        container.mainContext.insert(project)
        let viewModel = ProjectDetailViewModel(project: project)

        try viewModel.toggleMilestone(milestone, using: container.mainContext)
        try viewModel.setReadinessRequirement(
            .readme,
            isCompleted: true,
            for: project,
            using: container.mainContext
        )

        #expect(milestone.isCompleted == true)
        #expect(project.hasReadme == true)

        try viewModel.deleteMilestone(milestone, using: container.mainContext)

        let milestones = try container.mainContext.fetch(FetchDescriptor<ProjectMilestone>())
        #expect(milestones.isEmpty)
    }

    @MainActor
    @Test func milestoneOrderCanBeChangedAndControlsNextOpenStep() throws {
        let container = try makeProjectContainer()
        let project = PortfolioProject(title: "DevJourney")
        project.milestones = [
            ProjectMilestone(title: "MVP abschließen", sortOrder: 0),
            ProjectMilestone(title: "README schreiben", sortOrder: 1),
            ProjectMilestone(title: "Screenshots erstellen", sortOrder: 2),
        ]
        container.mainContext.insert(project)
        try container.mainContext.save()
        let viewModel = ProjectDetailViewModel(project: project)

        try viewModel.moveMilestones(
            fromOffsets: IndexSet(integer: 2),
            toOffset: 0,
            in: project,
            using: container.mainContext
        )

        #expect(project.orderedMilestones.map(\.title) == [
            "Screenshots erstellen",
            "MVP abschließen",
            "README schreiben",
        ])
        #expect(project.orderedMilestones.map(\.sortOrder) == [0, 1, 2])
        #expect(project.nextOpenStepTitle == "Screenshots erstellen")

        let persistedMilestones = try container.mainContext
            .fetch(FetchDescriptor<ProjectMilestone>())
            .sorted { $0.sortOrder < $1.sortOrder }
        #expect(
            persistedMilestones.map(\.title) == project.orderedMilestones.map(\.title)
        )
    }

    private func makePortfolioReadyProject() -> PortfolioProject {
        PortfolioProject(
            title: "DevJourney",
            isAppStable: true,
            hasTests: true,
            hasReadme: true,
            hasScreenshots: true,
            hasAppIcon: true,
            hasDocumentation: true
        )
    }

    @MainActor
    private func makeProjectContainer() throws -> ModelContainer {
        let schema = Schema([
            PortfolioProject.self,
            ProjectMilestone.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

}
