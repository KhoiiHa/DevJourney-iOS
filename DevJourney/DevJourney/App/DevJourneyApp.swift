//
//  DevJourneyApp.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI
import SwiftData

@main
struct DevJourneyApp: App {
    private let modelContainer = DevJourneyApp.makeModelContainer()

    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(modelContainer)
    }

    private static func makeModelContainer() -> ModelContainer {
        do {
            return try createModelContainer()
        } catch {
            #if DEBUG
            do {
                try resetPersistentStore()
                return try createModelContainer()
            } catch {
                fatalError("Could not recreate ModelContainer after resetting local store: \(error)")
            }
            #else
            fatalError("Could not create ModelContainer: \(error)")
            #endif
        }
    }

    private static func createModelContainer() throws -> ModelContainer {
        let schema = appSchema

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )

            return try ModelContainer(for: schema, configurations: [configuration])
        }
        #endif

        try createStoreDirectoryIfNeeded()

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private static var appSchema: Schema {
        Schema([
            LearningGoal.self,
            PortfolioProject.self,
            JobApplication.self,
        ])
    }

    private static var storeURL: URL {
        let applicationSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        return applicationSupportURL.appending(path: "DevJourney.store")
    }

    private static func resetPersistentStore() throws {
        try createStoreDirectoryIfNeeded()

        let storeFiles = [
            storeURL,
            storeURL.appendingPathExtension("shm"),
            storeURL.appendingPathExtension("wal")
        ]

        let fileManager = FileManager.default
        for fileURL in storeFiles where fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    private static func createStoreDirectoryIfNeeded() throws {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
}
