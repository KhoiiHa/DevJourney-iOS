//
//  ProjectMilestone.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 21.07.26.
//

import Foundation
import SwiftData

@Model
final class ProjectMilestone {
    var title: String
    var isCompleted: Bool
    var sortOrder: Int
    var createdAt: Date
    var project: PortfolioProject?

    init(
        title: String,
        isCompleted: Bool = false,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        project: PortfolioProject? = nil
    ) {
        self.title = title
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.project = project
    }
}
