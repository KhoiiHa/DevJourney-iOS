//
//  JobApplication.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import SwiftData

enum JobApplicationStatus {
    static let open = "Offen"
    static let applied = "Beworben"
    static let interview = "Interview"
    static let rejected = "Absage"
    static let offer = "Angebot"

    static let all = [open, applied, interview, rejected, offer]
}

@Model
final class JobApplication {
    var companyName: String
    var positionTitle: String
    var jobURL: String
    var status: String
    var appliedAt: Date?
    var nextAction: String = ""
    var followUpAt: Date?
    var createdAt: Date

    init(
        companyName: String,
        positionTitle: String,
        jobURL: String = "",
        status: String = JobApplicationStatus.open,
        appliedAt: Date? = nil,
        nextAction: String = "",
        followUpAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.companyName = companyName
        self.positionTitle = positionTitle
        self.jobURL = jobURL
        self.status = status
        self.appliedAt = appliedAt
        self.nextAction = nextAction
        self.followUpAt = followUpAt
        self.createdAt = createdAt
    }
}

extension JobApplication {
    var normalizedNextAction: String {
        nextAction.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasOpenFollowUp: Bool {
        !normalizedNextAction.isEmpty
    }

    func isFollowUpDue(
        on referenceDate: Date,
        calendar: Calendar = .current
    ) -> Bool {
        guard hasOpenFollowUp, let followUpAt else { return false }

        let startOfTomorrow = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: referenceDate)
        ) ?? referenceDate

        return followUpAt < startOfTomorrow
    }
}
