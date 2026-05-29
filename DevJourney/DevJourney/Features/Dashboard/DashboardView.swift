//
//  DashboardView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query private var goals: [LearningGoal]
    @Query private var projects: [PortfolioProject]
    @Query private var applications: [JobApplication]

    private let metricColumns = [
        GridItem(.adaptive(minimum: 120), spacing: 12)
    ]

    private var openGoalsCount: Int {
        goals.filter { !$0.isCompleted }.count
    }

    private var completedGoalsCount: Int {
        goals.filter(\.isCompleted).count
    }

    private var projectsCount: Int {
        projects.count
    }

    private var applicationsCount: Int {
        applications.count
    }

    private var openApplicationsCount: Int {
        applications.filter { $0.status == "Offen" }.count
    }

    private var interviewApplicationsCount: Int {
        applications.filter { $0.status == "Interview" }.count
    }

    private var offerApplicationsCount: Int {
        applications.filter { $0.status == "Angebot" }.count
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("DevJourney")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Lernziele, Portfolio-Projekte und Bewerbungen an einem Ort.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: metricColumns, spacing: 12) {
                    DashboardMetricView(
                        title: "Offen",
                        value: openGoalsCount,
                        systemImage: "circle"
                    )

                    DashboardMetricView(
                        title: "Erledigt",
                        value: completedGoalsCount,
                        systemImage: "checkmark.circle.fill"
                    )

                    DashboardMetricView(
                        title: "Projekte",
                        value: projectsCount,
                        systemImage: "folder"
                    )

                    DashboardMetricView(
                        title: "Bewerbungen",
                        value: applicationsCount,
                        systemImage: "briefcase"
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bewerbungsstatus")
                        .font(.headline)

                    HStack(spacing: 12) {
                        DashboardStatusView(title: "Offen", value: openApplicationsCount)
                        DashboardStatusView(title: "Interview", value: interviewApplicationsCount)
                        DashboardStatusView(title: "Angebot", value: offerApplicationsCount)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    NavigationLink {
                        GoalsView()
                    } label: {
                        Label("Lernziele öffnen", systemImage: "target")
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink {
                        ProjectsView()
                    } label: {
                        Label("Projekte öffnen", systemImage: "folder")
                    }
                    .buttonStyle(.bordered)

                    NavigationLink {
                        ApplicationsView()
                    } label: {
                        Label("Bewerbungen öffnen", systemImage: "briefcase")
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Dashboard")
        }
    }
}

private struct DashboardStatusView: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)")
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct DashboardMetricView: View {
    let title: String
    let value: Int
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.title2)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [LearningGoal.self, PortfolioProject.self, JobApplication.self], inMemory: true)
}
