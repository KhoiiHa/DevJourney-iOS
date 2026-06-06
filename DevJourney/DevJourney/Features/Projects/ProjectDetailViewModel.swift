//
//  ProjectDetailViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 30.05.26.
//

import Foundation
import Observation

@Observable
final class ProjectDetailViewModel {
    var title: String
    var summary: String
    var githubURL: String
    var notes: String
    var status: String

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
}
