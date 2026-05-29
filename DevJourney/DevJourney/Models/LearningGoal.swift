//
//  LearningGoal.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import SwiftData

@Model
final class LearningGoal {
    var title: String
    var details: String
    var isCompleted: Bool
    var createdAt: Date
    var targetDate: Date?

    init(
        title: String,
        details: String = "",
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        targetDate: Date? = nil
    ) {
        self.title = title
        self.details = details
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.targetDate = targetDate
    }
}
