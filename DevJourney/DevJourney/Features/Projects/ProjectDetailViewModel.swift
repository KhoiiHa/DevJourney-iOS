//
//  ProjectDetailViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 30.05.26.
//

import Foundation
import Observation
import SwiftData

@Observable
final class ProjectDetailViewModel {
    var title: String
    var summary: String
    var githubURL: String
    var notes: String
    var status: String
    var isShowingMilestoneEditor = false
    var milestoneTitle = ""

    private(set) var editingMilestone: ProjectMilestone?

    let availableStatuses = PortfolioProjectStatus.all

    var canSave: Bool {
        !trimmedTitle.isEmpty && hasValidGitHubURL
    }

    var validationMessage: String? {
        if trimmedTitle.isEmpty {
            return "Titel ist ein Pflichtfeld."
        }

        return hasValidGitHubURL ? nil : "Bitte gib einen gültigen GitHub-Link ein."
    }

    var validGitHubURL: URL? {
        trimmedGitHubURL.webURL
    }

    var hasNotes: Bool {
        !trimmedNotes.isEmpty
    }

    var milestoneEditorTitle: String {
        editingMilestone == nil ? "Meilenstein hinzufügen" : "Meilenstein bearbeiten"
    }

    var canSaveMilestone: Bool {
        !trimmedMilestoneTitle.isEmpty
    }

    init(project: PortfolioProject) {
        title = project.title
        summary = project.summary
        githubURL = project.githubURL
        notes = project.notes
        status = project.status
    }

    func save(to project: PortfolioProject) {
        guard canSave else {
            return
        }

        project.title = trimmedTitle
        project.summary = trimmedSummary
        project.githubURL = trimmedGitHubURL
        project.notes = trimmedNotes
        project.status = status
    }

    func orderedMilestones(for project: PortfolioProject) -> [ProjectMilestone] {
        project.orderedMilestones
    }

    func readinessProgressText(for project: PortfolioProject) -> String {
        "\(project.readinessCompletedCount) von \(project.readinessTotalCount)"
    }

    func readinessProgress(for project: PortfolioProject) -> Double {
        project.readinessProgress
    }

    func isReadinessRequirementCompleted(
        _ requirement: PortfolioReadinessRequirement,
        for project: PortfolioProject
    ) -> Bool {
        requirement.isCompleted(for: project)
    }

    func nextOpenStepTitle(for project: PortfolioProject) -> String? {
        project.nextOpenStepTitle
    }

    func startAddingMilestone() {
        editingMilestone = nil
        milestoneTitle = ""
        isShowingMilestoneEditor = true
    }

    func startEditingMilestone(_ milestone: ProjectMilestone) {
        editingMilestone = milestone
        milestoneTitle = milestone.title
        isShowingMilestoneEditor = true
    }

    func cancelMilestoneEditing() {
        editingMilestone = nil
        milestoneTitle = ""
        isShowingMilestoneEditor = false
    }

    func saveMilestone(
        to project: PortfolioProject,
        using modelContext: ModelContext
    ) throws {
        guard canSaveMilestone else { return }

        if let editingMilestone {
            editingMilestone.title = trimmedMilestoneTitle
        } else {
            let nextSortOrder = (project.milestones.map(\.sortOrder).max() ?? -1) + 1
            let milestone = ProjectMilestone(
                title: trimmedMilestoneTitle,
                sortOrder: nextSortOrder
            )
            project.milestones.append(milestone)
            modelContext.insert(milestone)
        }

        try saveChanges(using: modelContext)
        cancelMilestoneEditing()
    }

    func toggleMilestone(
        _ milestone: ProjectMilestone,
        using modelContext: ModelContext
    ) throws {
        milestone.isCompleted.toggle()
        try saveChanges(using: modelContext)
    }

    func deleteMilestone(
        _ milestone: ProjectMilestone,
        using modelContext: ModelContext
    ) throws {
        modelContext.delete(milestone)
        try saveChanges(using: modelContext)
    }

    func setReadinessRequirement(
        _ requirement: PortfolioReadinessRequirement,
        isCompleted: Bool,
        for project: PortfolioProject,
        using modelContext: ModelContext
    ) throws {
        switch requirement {
        case .stableApp:
            project.isAppStable = isCompleted
        case .tests:
            project.hasTests = isCompleted
        case .readme:
            project.hasReadme = isCompleted
        case .screenshots:
            project.hasScreenshots = isCompleted
        case .appIcon:
            project.hasAppIcon = isCompleted
        case .documentation:
            project.hasDocumentation = isCompleted
        }

        try saveChanges(using: modelContext)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedSummary: String {
        summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedGitHubURL: String {
        githubURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasValidGitHubURL: Bool {
        trimmedGitHubURL.isEmpty || validGitHubURL != nil
    }

    private var trimmedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedMilestoneTitle: String {
        milestoneTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveChanges(using modelContext: ModelContext) throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
