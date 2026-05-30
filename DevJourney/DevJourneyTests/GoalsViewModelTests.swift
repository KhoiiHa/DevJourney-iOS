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

}
