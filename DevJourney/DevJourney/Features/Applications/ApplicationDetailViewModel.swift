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
    var nextAction: String
    var hasFollowUpDate: Bool
    var followUpAt: Date

    let availableStatuses = JobApplicationStatus.all

    var canSave: Bool {
        !trimmedCompanyName.isEmpty &&
            !trimmedPositionTitle.isEmpty &&
            hasValidJobURL &&
            hasValidFollowUp
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

        if !hasValidJobURL {
            return "Bitte gib einen gültigen Stellenanzeigen-Link ein."
        }

        return hasValidFollowUp ? nil : "Ergänze eine nächste Aktion für das Follow-up-Datum."
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
        nextAction = application.nextAction
        hasFollowUpDate = application.followUpAt != nil
        followUpAt = application.followUpAt ?? Date()
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
        application.nextAction = trimmedNextAction
        application.followUpAt = hasFollowUpDate ? followUpAt : nil
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

    private var trimmedNextAction: String {
        nextAction.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasValidJobURL: Bool {
        trimmedJobURL.isEmpty || validJobURL != nil
    }

    private var hasValidFollowUp: Bool {
        !hasFollowUpDate || !trimmedNextAction.isEmpty
    }
}
