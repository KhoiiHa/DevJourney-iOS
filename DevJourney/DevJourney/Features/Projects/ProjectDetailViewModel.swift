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
        !trimmedTitle.isEmpty
    }

    var validationMessage: String? {
        canSave ? nil : "Titel ist ein Pflichtfeld."
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

    private var trimmedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
