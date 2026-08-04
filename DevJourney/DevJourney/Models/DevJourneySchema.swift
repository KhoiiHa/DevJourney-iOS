//
//  DevJourneySchema.swift
//  DevJourney
//
//  Created by Codex on 22.07.26.
//

import Foundation
import SwiftData

enum DevJourneySchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    @Model
    final class JobApplication {
        var companyName: String
        var positionTitle: String
        var jobURL: String
        var status: String
        var appliedAt: Date?
        var createdAt: Date

        init(
            companyName: String,
            positionTitle: String,
            jobURL: String = "",
            status: String = JobApplicationStatus.open,
            appliedAt: Date? = nil,
            createdAt: Date = Date()
        ) {
            self.companyName = companyName
            self.positionTitle = positionTitle
            self.jobURL = jobURL
            self.status = status
            self.appliedAt = appliedAt
            self.createdAt = createdAt
        }
    }

    static var models: [any PersistentModel.Type] {
        [
            LearningGoal.self,
            PortfolioProject.self,
            ProjectMilestone.self,
            JobApplication.self,
        ]
    }
}

enum DevJourneySchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

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
        [DevJourneySchemaV1.self, DevJourneySchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: DevJourneySchemaV1.self,
                toVersion: DevJourneySchemaV2.self
            ),
        ]
    }
}
