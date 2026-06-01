//
//  GoalsViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import Observation
import SwiftData

@Observable
final class GoalsViewModel {
    var newGoalTitle = ""
    var isShowingAddGoal = false

    var canAddGoal: Bool {
        !trimmedTitle.isEmpty
    }

    var validationMessage: String? {
        canAddGoal ? nil : "Titel ist ein Pflichtfeld."
    }

    func startAddingGoal() {
        isShowingAddGoal = true
    }

    func cancelAddingGoal() {
        resetForm()
    }

    func addGoal(using modelContext: ModelContext) throws {
        guard canAddGoal else {
            return
        }

        let goal = LearningGoal(title: trimmedTitle)
        modelContext.insert(goal)
        try modelContext.save()
        resetForm()
    }

    func deleteGoals(at offsets: IndexSet, from goals: [LearningGoal], using modelContext: ModelContext) {
        for index in offsets {
            modelContext.delete(goals[index])
        }
    }

    func toggleCompletion(for goal: LearningGoal) {
        goal.isCompleted.toggle()
    }

    private func resetForm() {
        newGoalTitle = ""
        isShowingAddGoal = false
    }

    private var trimmedTitle: String {
        newGoalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
