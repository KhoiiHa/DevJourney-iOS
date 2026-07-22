//
//  ProjectsViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import Observation
import SwiftData

enum ProjectListFilter: String, CaseIterable, Identifiable {
    case all
    case needsAttention
    case portfolioReady

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            "Alle"
        case .needsAttention:
            "Aufmerksamkeit"
        case .portfolioReady:
            "Bereit"
        }
    }
}

@Observable
final class ProjectsViewModel {
    var newProjectTitle = ""
    var newProjectSummary = ""
    var newProjectGitHubURL = ""
    var newProjectNotes = ""
    var newProjectStatus = PortfolioProjectStatus.planned
    var isShowingAddProject = false
    var selectedFilter = ProjectListFilter.all

    let availableStatuses = PortfolioProjectStatus.all
    let availableFilters = ProjectListFilter.allCases

    var canAddProject: Bool {
        !trimmedTitle.isEmpty && hasValidGitHubURL
    }

    var validationMessage: String? {
        if trimmedTitle.isEmpty {
            return "Titel ist ein Pflichtfeld."
        }

        return hasValidGitHubURL ? nil : "Bitte gib einen gültigen GitHub-Link ein."
    }

    func readinessProgress(for project: PortfolioProject) -> Double {
        project.readinessProgress
    }

    func readinessProgressText(for project: PortfolioProject) -> String {
        "\(project.readinessCompletedCount) von \(project.readinessTotalCount)"
    }

    func nextStepText(for project: PortfolioProject) -> String {
        guard let nextStep = project.nextOpenStepTitle else {
            return "Portfolio-bereit"
        }

        return "Als Nächstes: \(nextStep)"
    }

    func hasOpenStep(for project: PortfolioProject) -> Bool {
        project.nextOpenStepTitle != nil
    }

    func visibleProjects(
        from projects: [PortfolioProject],
        matching searchText: String
    ) -> [PortfolioProject] {
        let normalizedSearchText = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return projects
            .filter { project in
                matchesSelectedFilter(project) &&
                    matchesSearch(project, searchText: normalizedSearchText)
            }
            .sorted { firstProject, secondProject in
                let firstPriority = priority(for: firstProject.status)
                let secondPriority = priority(for: secondProject.status)

                if firstPriority == secondPriority {
                    return firstProject.createdAt > secondProject.createdAt
                }

                return firstPriority < secondPriority
            }
    }

    func startAddingProject() {
        isShowingAddProject = true
    }

    func cancelAddingProject() {
        resetForm()
    }

    func addProject(using modelContext: ModelContext) throws {
        guard canAddProject else {
            return
        }

        let project = PortfolioProject(
            title: trimmedTitle,
            summary: trimmedSummary,
            githubURL: trimmedGitHubURL,
            notes: trimmedNotes,
            status: newProjectStatus
        )
        modelContext.insert(project)

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }

        resetForm()
    }

    private func resetForm() {
        newProjectTitle = ""
        newProjectSummary = ""
        newProjectGitHubURL = ""
        newProjectNotes = ""
        newProjectStatus = PortfolioProjectStatus.planned
        isShowingAddProject = false
    }

    private func matchesSelectedFilter(_ project: PortfolioProject) -> Bool {
        switch selectedFilter {
        case .all:
            true
        case .needsAttention:
            project.openActionCount > 0
        case .portfolioReady:
            project.isPortfolioReady
        }
    }

    private func matchesSearch(
        _ project: PortfolioProject,
        searchText: String
    ) -> Bool {
        guard !searchText.isEmpty else { return true }

        return project.title.localizedStandardContains(searchText) ||
            project.summary.localizedStandardContains(searchText) ||
            project.githubURL.localizedStandardContains(searchText)
    }

    private func priority(for status: String) -> Int {
        switch status {
        case PortfolioProjectStatus.inProgress:
            0
        case PortfolioProjectStatus.completed:
            2
        default:
            1
        }
    }

    private var trimmedTitle: String {
        newProjectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedSummary: String {
        newProjectSummary.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedGitHubURL: String {
        newProjectGitHubURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasValidGitHubURL: Bool {
        trimmedGitHubURL.isEmpty || trimmedGitHubURL.webURL != nil
    }

    private var trimmedNotes: String {
        newProjectNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
