//
//  DashboardViewModel.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 21.07.26.
//

import Foundation

struct DashboardPortfolioSummary {
    let readyProjectsCount: Int
    let attentionProject: PortfolioProject?

    var attentionOpenActionCount: Int {
        attentionProject?.openActionCount ?? 0
    }

    var nextStepTitle: String? {
        attentionProject?.nextOpenStepTitle
    }
}

struct DashboardViewModel {
    func portfolioSummary(for projects: [PortfolioProject]) -> DashboardPortfolioSummary {
        DashboardPortfolioSummary(
            readyProjectsCount: projects.count(where: \.isPortfolioReady),
            attentionProject: attentionProject(from: projects)
        )
    }

    private func attentionProject(from projects: [PortfolioProject]) -> PortfolioProject? {
        projects
            .filter { $0.openActionCount > 0 }
            .sorted(by: shouldPrioritize)
            .first
    }

    private func shouldPrioritize(
        _ firstProject: PortfolioProject,
        _ secondProject: PortfolioProject
    ) -> Bool {
        if firstProject.openActionCount != secondProject.openActionCount {
            return firstProject.openActionCount > secondProject.openActionCount
        }

        if firstProject.createdAt != secondProject.createdAt {
            return firstProject.createdAt < secondProject.createdAt
        }

        return firstProject.title.localizedStandardCompare(secondProject.title) == .orderedAscending
    }
}
