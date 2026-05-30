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
    var createdAt: Date

    init(
        companyName: String,
        positionTitle: String,
        jobURL: String = "",
        status: String = JobApplicationStatus.open,
        appliedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.companyName = companyName
        self.positionTitle = positionTitle
        self.jobURL = jobURL
        self.status = status
        self.appliedAt = appliedAt
        self.createdAt = createdAt
    }
}
