//
//  DevJourneySchema.swift
//  DevJourney
//
//  Created by Codex on 22.07.26.
//

import SwiftData

enum DevJourneySchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            LearningGoal.self,
            PortfolioProject.self,
            ProjectMilestone.self,
            JobApplication.self,
        ]
    }
}

enum DevJourneyMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [DevJourneySchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
