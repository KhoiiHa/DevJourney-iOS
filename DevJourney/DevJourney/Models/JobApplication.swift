//
//  JobApplication.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import SwiftData

@Model
final class JobApplication {
    var companyName: String
    var positionTitle: String
    var status: String
    var appliedAt: Date?
    var createdAt: Date

    init(
        companyName: String,
        positionTitle: String,
        status: String = "Offen",
        appliedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.companyName = companyName
        self.positionTitle = positionTitle
        self.status = status
        self.appliedAt = appliedAt
        self.createdAt = createdAt
    }
}
