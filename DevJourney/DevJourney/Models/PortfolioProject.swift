//
//  PortfolioProject.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import SwiftData

@Model
final class PortfolioProject {
    var title: String
    var summary: String
    var status: String
    var createdAt: Date

    init(
        title: String,
        summary: String = "",
        status: String = "Geplant",
        createdAt: Date = Date()
    ) {
        self.title = title
        self.summary = summary
        self.status = status
        self.createdAt = createdAt
    }
}
