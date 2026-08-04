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
    @Test func v2ContainerPreservesExistingUnversionedStore() throws {
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
        try verifyV2Store(at: storeURL)
    }

    @MainActor
    @Test func v2ContainerMigratesVersionedV1Store() throws {
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

        try seedV1Store(at: storeURL, isVersioned: true)
        try verifyV2Store(at: storeURL)
    }

    @MainActor
    private func seedLegacyStore(at storeURL: URL) throws {
        try seedV1Store(at: storeURL, isVersioned: false)
    }

    @MainActor
    private func seedV1Store(at storeURL: URL, isVersioned: Bool) throws {
        let schema = isVersioned
            ? Schema(versionedSchema: DevJourneySchemaV1.self)
            : Schema(DevJourneySchemaV1.models)
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
            DevJourneySchemaV1.JobApplication(
                companyName: "Example GmbH",
                positionTitle: "Junior iOS Developer"
            )
        )
        try context.save()
    }

    @MainActor
    private func verifyV2Store(at storeURL: URL) throws {
        let schema = Schema(versionedSchema: DevJourneySchemaV2.self)
        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(
            for: schema,
            migrationPlan: DevJourneyMigrationPlan.self,
            configurations: [configuration]
        )
        let context = container.mainContext

        #expect(container.schema.version == DevJourneySchemaV2.versionIdentifier)
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
        #expect(applications.first?.nextAction == "")
        #expect(applications.first?.followUpAt == nil)
    }
}
