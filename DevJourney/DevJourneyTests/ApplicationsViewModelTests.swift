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
        #expect(viewModel.validationMessage == "Firma und Position sind Pflichtfelder.")
        #expect(viewModel.status == JobApplicationStatus.open)

        viewModel.companyName = "Apple"

        #expect(viewModel.validationMessage == "Position ist ein Pflichtfeld.")

        viewModel.companyName = ""
        viewModel.positionTitle = "iOS Developer"

        #expect(viewModel.validationMessage == "Firma ist ein Pflichtfeld.")

        viewModel.companyName = "Apple"

        #expect(viewModel.canAddApplication == true)
        #expect(viewModel.validationMessage == nil)
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

        try viewModel.addApplication(using: container.mainContext)

        let applications = try container.mainContext.fetch(FetchDescriptor<JobApplication>())
        #expect(applications.first?.jobURL == "https://jobs.apple.com/example")
    }

    @Test func applicationRequiresValidJobURLWhenProvided() {
        let viewModel = ApplicationsViewModel()
        viewModel.companyName = "Apple"
        viewModel.positionTitle = "iOS Developer"

        #expect(viewModel.canAddApplication == true)

        viewModel.jobURL = "jobs.apple.com/example"

        #expect(viewModel.canAddApplication == false)
        #expect(viewModel.validationMessage == "Bitte gib einen gültigen Stellenanzeigen-Link ein.")

        viewModel.jobURL = "https://jobs.apple.com/example"

        #expect(viewModel.canAddApplication == true)
        #expect(viewModel.validationMessage == nil)
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
        #expect(viewModel.validationMessage == "Firma ist ein Pflichtfeld.")

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
        #expect(viewModel.validationMessage == nil)
    }

    @Test func applicationDetailExposesOnlyValidWebURL() {
        let application = JobApplication(
            companyName: "Apple",
            positionTitle: "iOS Developer"
        )
        let viewModel = ApplicationDetailViewModel(application: application)

        viewModel.jobURL = "mailto:jobs@example.com"

        #expect(viewModel.canSave == false)
        #expect(viewModel.validJobURL == nil)

        viewModel.jobURL = " https://jobs.apple.com/example "

        #expect(viewModel.canSave == true)
        #expect(viewModel.validJobURL?.absoluteString == "https://jobs.apple.com/example")
    }

}
