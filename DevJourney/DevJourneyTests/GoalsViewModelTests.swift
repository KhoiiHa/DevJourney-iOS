//
//  GoalsViewModelTests.swift
//  DevJourneyTests
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Testing
@testable import DevJourney

struct GoalsViewModelTests {

    @Test func goalRequiresNonEmptyTitle() {
        let viewModel = GoalsViewModel()

        #expect(viewModel.canAddGoal == false)

        viewModel.newGoalTitle = "  SwiftUI lernen  "

        #expect(viewModel.canAddGoal == true)
    }

    @Test func goalDetailRequiresTitleAndSavesTrimmedValues() {
        let goal = LearningGoal(title: "SwiftUI lernen")
        let viewModel = GoalDetailViewModel(goal: goal)

        viewModel.title = "  "

        #expect(viewModel.canSave == false)

        viewModel.title = "  SwiftData verstehen  "
        viewModel.details = "  Persistente Daten im MVP nutzen  "
        viewModel.isCompleted = true
        viewModel.hasTargetDate = false
        viewModel.save(to: goal)

        #expect(goal.title == "SwiftData verstehen")
        #expect(goal.details == "Persistente Daten im MVP nutzen")
        #expect(goal.isCompleted == true)
        #expect(goal.targetDate == nil)
    }

}
