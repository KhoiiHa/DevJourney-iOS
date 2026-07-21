//
//  PortfolioProject.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import SwiftData

enum PortfolioProjectStatus {
    static let planned = "Geplant"
    static let inProgress = "In Arbeit"
    static let completed = "Abgeschlossen"

    static let all = [planned, inProgress, completed]
}

enum PortfolioReadinessRequirement: String, CaseIterable, Identifiable {
    case stableApp
    case tests
    case readme
    case screenshots
    case appIcon
    case documentation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stableApp:
            "App funktioniert stabil"
        case .tests:
            "Tests vorhanden"
        case .readme:
            "README fertig"
        case .screenshots:
            "Screenshots vorhanden"
        case .appIcon:
            "App Icon vorhanden"
        case .documentation:
            "Case Study oder Projektdokumentation vorhanden"
        }
    }

    func isCompleted(for project: PortfolioProject) -> Bool {
        switch self {
        case .stableApp:
            project.isAppStable
        case .tests:
            project.hasTests
        case .readme:
            project.hasReadme
        case .screenshots:
            project.hasScreenshots
        case .appIcon:
            project.hasAppIcon
        case .documentation:
            project.hasDocumentation
        }
    }
}

@Model
final class PortfolioProject {
    var title: String
    var summary: String
    var githubURL: String
    var notes: String
    var status: String
    var createdAt: Date
    var isAppStable: Bool = false
    var hasTests: Bool = false
    var hasReadme: Bool = false
    var hasScreenshots: Bool = false
    var hasAppIcon: Bool = false
    var hasDocumentation: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \ProjectMilestone.project)
    var milestones: [ProjectMilestone] = []

    init(
        title: String,
        summary: String = "",
        githubURL: String = "",
        notes: String = "",
        status: String = PortfolioProjectStatus.planned,
        createdAt: Date = Date(),
        isAppStable: Bool = false,
        hasTests: Bool = false,
        hasReadme: Bool = false,
        hasScreenshots: Bool = false,
        hasAppIcon: Bool = false,
        hasDocumentation: Bool = false,
        milestones: [ProjectMilestone] = []
    ) {
        self.title = title
        self.summary = summary
        self.githubURL = githubURL
        self.notes = notes
        self.status = status
        self.createdAt = createdAt
        self.isAppStable = isAppStable
        self.hasTests = hasTests
        self.hasReadme = hasReadme
        self.hasScreenshots = hasScreenshots
        self.hasAppIcon = hasAppIcon
        self.hasDocumentation = hasDocumentation
        self.milestones = milestones
    }
}

extension PortfolioProject {
    var readinessCompletedCount: Int {
        PortfolioReadinessRequirement.allCases.count {
            $0.isCompleted(for: self)
        }
    }

    var readinessTotalCount: Int {
        PortfolioReadinessRequirement.allCases.count
    }

    var readinessProgress: Double {
        guard readinessTotalCount > 0 else { return 0 }
        return Double(readinessCompletedCount) / Double(readinessTotalCount)
    }

    var isPortfolioReady: Bool {
        readinessTotalCount > 0 && readinessCompletedCount == readinessTotalCount
    }

    var orderedMilestones: [ProjectMilestone] {
        milestones.sorted {
            if $0.sortOrder == $1.sortOrder {
                return $0.createdAt < $1.createdAt
            }
            return $0.sortOrder < $1.sortOrder
        }
    }

    var nextOpenStepTitle: String? {
        if let milestone = orderedMilestones.first(where: { !$0.isCompleted }) {
            return milestone.title
        }

        return PortfolioReadinessRequirement.allCases
            .first(where: { !$0.isCompleted(for: self) })?
            .title
    }

    var openActionCount: Int {
        let openMilestones = milestones.count { !$0.isCompleted }
        let openReadinessRequirements = readinessTotalCount - readinessCompletedCount
        return openMilestones + openReadinessRequirements
    }
}
