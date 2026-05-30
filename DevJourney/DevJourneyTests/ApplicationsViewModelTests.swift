//
//  ApplicationsViewModelTests.swift
//  DevJourneyTests
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import SwiftData
import Testing
@testable import DevJourney

struct ApplicationsViewModelTests {

    @Test func applicationUsesDefaultStatusAndRequiresCompanyAndPosition() {
        let viewModel = ApplicationsViewModel()

        #expect(viewModel.canAddApplication == false)
        #expect(viewModel.status == JobApplicationStatus.open)

        viewModel.companyName = "Apple"
        viewModel.positionTitle = "iOS Developer"

        #expect(viewModel.canAddApplication == true)
    }

    @MainActor
    @Test func applicationJobURLIsTrimmedWhenAdded() throws {
        let container = try ModelContainer(
            for: JobApplication.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = ApplicationsViewModel()
        viewModel.companyName = "Apple"
        viewModel.positionTitle = "iOS Developer"
        viewModel.jobURL = " https://jobs.apple.com/example "

        viewModel.addApplication(using: container.mainContext)

        let applications = try container.mainContext.fetch(FetchDescriptor<JobApplication>())
        #expect(applications.first?.jobURL == "https://jobs.apple.com/example")
    }

    @Test func applicationDetailRequiresCompanyAndPositionAndSavesTrimmedValues() {
        let date = Date()
        let application = JobApplication(
            companyName: "Apple",
            positionTitle: "iOS Developer",
            appliedAt: date
        )
        let viewModel = ApplicationDetailViewModel(application: application)

        viewModel.companyName = "  "

        #expect(viewModel.canSave == false)

        viewModel.companyName = "  OpenAI  "
        viewModel.positionTitle = "  iOS Engineer  "
        viewModel.jobURL = " https://jobs.example.com/ios "
        viewModel.status = JobApplicationStatus.interview
        viewModel.hasAppliedDate = false
        viewModel.save(to: application)

        #expect(application.companyName == "OpenAI")
        #expect(application.positionTitle == "iOS Engineer")
        #expect(application.jobURL == "https://jobs.example.com/ios")
        #expect(application.status == JobApplicationStatus.interview)
        #expect(application.appliedAt == nil)
    }

}
