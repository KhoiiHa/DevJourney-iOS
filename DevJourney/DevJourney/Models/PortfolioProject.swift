//
//  PortfolioProject.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import SwiftData

enum PortfolioProjectStatus {
    static let planned = "Geplant"
    static let inProgress = "In Arbeit"
    static let completed = "Abgeschlossen"

    static let all = [planned, inProgress, completed]
}

@Model
final class PortfolioProject {
    var title: String
    var summary: String
    var githubURL: String
    var status: String
    var createdAt: Date

    init(
        title: String,
        summary: String = "",
        githubURL: String = "",
        status: String = PortfolioProjectStatus.planned,
        createdAt: Date = Date()
    ) {
        self.title = title
        self.summary = summary
        self.githubURL = githubURL
        self.status = status
        self.createdAt = createdAt
    }
}
