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

    var validationMessage: String? {
        if canAddApplication {
            return nil
        }

        if trimmedCompanyName.isEmpty && trimmedPositionTitle.isEmpty {
            return "Firma und Position sind Pflichtfelder."
        }

        if trimmedCompanyName.isEmpty {
            return "Firma ist ein Pflichtfeld."
        }

        return "Position ist ein Pflichtfeld."
    }

    func startAddingApplication() {
        isShowingAddApplication = true
    }

    func cancelAddingApplication() {
        resetForm()
    }

    func addApplication(using modelContext: ModelContext) throws {
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

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }

        resetForm()
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
