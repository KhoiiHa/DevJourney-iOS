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

struct DashboardApplicationFollowUpSummary {
    let dueCount: Int
    let nextApplication: JobApplication?

    var nextActionTitle: String? {
        nextApplication?.normalizedNextAction
    }
}

struct DashboardViewModel {
    func portfolioSummary(for projects: [PortfolioProject]) -> DashboardPortfolioSummary {
        DashboardPortfolioSummary(
            readyProjectsCount: projects.count(where: \.isPortfolioReady),
            attentionProject: attentionProject(from: projects)
        )
    }

    func applicationFollowUpSummary(
        for applications: [JobApplication],
        on referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> DashboardApplicationFollowUpSummary {
        let openFollowUps = applications.filter(\.hasOpenFollowUp)

        return DashboardApplicationFollowUpSummary(
            dueCount: openFollowUps.count {
                $0.isFollowUpDue(on: referenceDate, calendar: calendar)
            },
            nextApplication: openFollowUps.sorted(by: shouldPrioritizeFollowUp).first
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

    private func shouldPrioritizeFollowUp(
        _ firstApplication: JobApplication,
        _ secondApplication: JobApplication
    ) -> Bool {
        switch (firstApplication.followUpAt, secondApplication.followUpAt) {
        case let (firstDate?, secondDate?) where firstDate != secondDate:
            return firstDate < secondDate
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            break
        }

        if firstApplication.createdAt != secondApplication.createdAt {
            return firstApplication.createdAt < secondApplication.createdAt
        }

        return firstApplication.companyName.localizedStandardCompare(
            secondApplication.companyName
        ) == .orderedAscending
    }
}
