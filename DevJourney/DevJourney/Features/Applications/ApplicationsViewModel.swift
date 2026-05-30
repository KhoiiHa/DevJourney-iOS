//
//  ApplicationsViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import Observation
import SwiftData

@Observable
final class ApplicationsViewModel {
    var companyName = ""
    var positionTitle = ""
    var jobURL = ""
    var status = JobApplicationStatus.open
    var hasAppliedDate = false
    var appliedAt = Date()
    var isShowingAddApplication = false

    let availableStatuses = JobApplicationStatus.all

    var canAddApplication: Bool {
        !trimmedCompanyName.isEmpty && !trimmedPositionTitle.isEmpty
    }

    func startAddingApplication() {
        isShowingAddApplication = true
    }

    func cancelAddingApplication() {
        resetForm()
    }

    func addApplication(using modelContext: ModelContext) {
        guard canAddApplication else {
            return
        }

        let application = JobApplication(
            companyName: trimmedCompanyName,
            positionTitle: trimmedPositionTitle,
            jobURL: trimmedJobURL,
            status: status,
            appliedAt: hasAppliedDate ? appliedAt : nil
        )
        modelContext.insert(application)
        resetForm()
    }

    func deleteApplications(at offsets: IndexSet, from applications: [JobApplication], using modelContext: ModelContext) {
        for index in offsets {
            modelContext.delete(applications[index])
        }
    }

    private func resetForm() {
        companyName = ""
        positionTitle = ""
        jobURL = ""
        status = JobApplicationStatus.open
        hasAppliedDate = false
        appliedAt = Date()
        isShowingAddApplication = false
    }

    private var trimmedCompanyName: String {
        companyName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPositionTitle: String {
        positionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedJobURL: String {
        jobURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
