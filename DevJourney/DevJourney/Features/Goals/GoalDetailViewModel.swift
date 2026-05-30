//
//  GoalDetailViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 30.05.26.
//

import Foundation
import Observation

@Observable
final class GoalDetailViewModel {
    var title: String
    var details: String
    var isCompleted: Bool
    var hasTargetDate: Bool
    var targetDate: Date

    var canSave: Bool {
        !trimmedTitle.isEmpty
    }

    init(goal: LearningGoal) {
        title = goal.title
        details = goal.details
        isCompleted = goal.isCompleted
        hasTargetDate = goal.targetDate != nil
        targetDate = goal.targetDate ?? Date()
    }

    func save(to goal: LearningGoal) {
        guard canSave else {
            return
        }

        goal.title = trimmedTitle
        goal.details = trimmedDetails
        goal.isCompleted = isCompleted
        goal.targetDate = hasTargetDate ? targetDate : nil
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedDetails: String {
        details.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
