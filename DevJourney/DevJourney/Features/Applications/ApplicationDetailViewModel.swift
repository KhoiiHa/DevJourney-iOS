//
//  ApplicationDetailViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 30.05.26.
//

import Foundation
import Observation

@Observable
final class ApplicationDetailViewModel {
    var companyName: String
    var positionTitle: String
    var jobURL: String
    var status: String
    var hasAppliedDate: Bool
    var appliedAt: Date

    let availableStatuses = JobApplicationStatus.all

    var canSave: Bool {
        !trimmedCompanyName.isEmpty && !trimmedPositionTitle.isEmpty && hasValidJobURL
    }

    var validationMessage: String? {
        if canSave {
            return nil
        }

        if trimmedCompanyName.isEmpty && trimmedPositionTitle.isEmpty {
            return "Firma und Position sind Pflichtfelder."
        }

        if trimmedCompanyName.isEmpty {
            return "Firma ist ein Pflichtfeld."
        }

        if trimmedPositionTitle.isEmpty {
            return "Position ist ein Pflichtfeld."
        }

        return hasValidJobURL ? nil : "Bitte gib einen gültigen Stellenanzeigen-Link ein."
    }

    var validJobURL: URL? {
        trimmedJobURL.webURL
    }

    init(application: JobApplication) {
        companyName = application.companyName
        positionTitle = application.positionTitle
        jobURL = application.jobURL
        status = application.status
        hasAppliedDate = application.appliedAt != nil
        appliedAt = application.appliedAt ?? Date()
    }

    func save(to application: JobApplication) {
        guard canSave else {
            return
        }

        application.companyName = trimmedCompanyName
        application.positionTitle = trimmedPositionTitle
        application.jobURL = trimmedJobURL
        application.status = status
        application.appliedAt = hasAppliedDate ? appliedAt : nil
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

    private var hasValidJobURL: Bool {
        trimmedJobURL.isEmpty || validJobURL != nil
    }
}
