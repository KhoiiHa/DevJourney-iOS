//
//  DevJourneySchemaMigrationTests.swift
//  DevJourneyTests
//
//  Created by Codex on 22.07.26.
//

import Foundation
import SwiftData
import Testing
@testable import DevJourney

@Suite(.serialized)
struct DevJourneySchemaMigrationTests {

    @MainActor
    @Test func versionedContainerPreservesExistingUnversionedStore() throws {
        let storeDirectory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        let storeURL = storeDirectory.appending(path: "DevJourney.store")

        try FileManager.default.createDirectory(
            at: storeDirectory,
            withIntermediateDirectories: true
        )
        defer {
            try? FileManager.default.removeItem(at: storeDirectory)
        }

        try seedLegacyStore(at: storeURL)
        try verifyVersionedStore(at: storeURL)
    }

    @MainActor
    private func seedLegacyStore(at storeURL: URL) throws {
        let schema = Schema(DevJourneySchemaV1.models)
        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        let context = container.mainContext

        let project = PortfolioProject(
            title: "DevJourney",
            isAppStable: true,
            hasTests: true
        )
        project.milestones = [
            ProjectMilestone(title: "README abschließen"),
        ]

        context.insert(LearningGoal(title: "SwiftData verstehen"))
        context.insert(project)
        context.insert(
            JobApplication(
                companyName: "Example GmbH",
                positionTitle: "Junior iOS Developer"
            )
        )
        try context.save()
    }

    @MainActor
    private func verifyVersionedStore(at storeURL: URL) throws {
        let schema = Schema(versionedSchema: DevJourneySchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(
            for: schema,
            migrationPlan: DevJourneyMigrationPlan.self,
            configurations: [configuration]
        )
        let context = container.mainContext

        #expect(container.schema.version == DevJourneySchemaV1.versionIdentifier)
        #expect(container.migrationPlan != nil)

        let goals = try context.fetch(FetchDescriptor<LearningGoal>())
        let projects = try context.fetch(FetchDescriptor<PortfolioProject>())
        let milestones = try context.fetch(FetchDescriptor<ProjectMilestone>())
        let applications = try context.fetch(FetchDescriptor<JobApplication>())

        #expect(goals.map(\.title) == ["SwiftData verstehen"])
        #expect(projects.map(\.title) == ["DevJourney"])
        #expect(projects.first?.isAppStable == true)
        #expect(projects.first?.hasTests == true)
        #expect(milestones.map(\.title) == ["README abschließen"])
        #expect(applications.map(\.companyName) == ["Example GmbH"])
    }
}
