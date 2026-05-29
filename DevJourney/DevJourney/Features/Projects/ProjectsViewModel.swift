//
//  ProjectsViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import Observation
import SwiftData

@Observable
final class ProjectsViewModel {
    var newProjectTitle = ""
    var newProjectSummary = ""
    var newProjectStatus = PortfolioProjectStatus.planned
    var isShowingAddProject = false

    let availableStatuses = PortfolioProjectStatus.all

    var canAddProject: Bool {
        !trimmedTitle.isEmpty
    }

    func startAddingProject() {
        isShowingAddProject = true
    }

    func cancelAddingProject() {
        resetForm()
    }

    func addProject(using modelContext: ModelContext) {
        guard canAddProject else {
            return
        }

        let project = PortfolioProject(
            title: trimmedTitle,
            summary: trimmedSummary,
            status: newProjectStatus
        )
        modelContext.insert(project)
        resetForm()
    }

    func deleteProjects(at offsets: IndexSet, from projects: [PortfolioProject], using modelContext: ModelContext) {
        for index in offsets {
            modelContext.delete(projects[index])
        }
    }

    private func resetForm() {
        newProjectTitle = ""
        newProjectSummary = ""
        newProjectStatus = PortfolioProjectStatus.planned
        isShowingAddProject = false
    }

    private var trimmedTitle: String {
        newProjectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedSummary: String {
        newProjectSummary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
