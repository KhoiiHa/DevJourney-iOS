//
//  DevJourneyTests.swift
//  DevJourneyTests
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Testing
@testable import DevJourney

struct DevJourneyTests {

    @Test func goalRequiresNonEmptyTitle() {
        let viewModel = GoalsViewModel()

        #expect(viewModel.canAddGoal == false)

        viewModel.newGoalTitle = "  SwiftUI lernen  "

        #expect(viewModel.canAddGoal == true)
    }

    @Test func projectUsesDefaultStatusAndRequiresTitle() {
        let viewModel = ProjectsViewModel()

        #expect(viewModel.canAddProject == false)
        #expect(viewModel.newProjectStatus == PortfolioProjectStatus.planned)

        viewModel.newProjectTitle = "DevJourney"

        #expect(viewModel.canAddProject == true)
    }

    @Test func applicationUsesDefaultStatusAndRequiresCompanyAndPosition() {
        let viewModel = ApplicationsViewModel()

        #expect(viewModel.canAddApplication == false)
        #expect(viewModel.status == JobApplicationStatus.open)

        viewModel.companyName = "Apple"
        viewModel.positionTitle = "iOS Developer"

        #expect(viewModel.canAddApplication == true)
    }

}
