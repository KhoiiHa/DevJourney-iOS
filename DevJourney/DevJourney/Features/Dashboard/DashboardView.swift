//
//  DashboardView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Charts
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

    private var applicationStatusChartData: [DashboardChartValue] {
        JobApplicationStatus.all.map { status in
            DashboardChartValue(
                title: status,
                value: applications.filter { $0.status == status }.count
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("DevJourney")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Lernziele, Portfolio-Projekte und Bewerbungen an einem Ort.")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: metricColumns, spacing: 12) {
                        DashboardMetricView(
                            title: "Offene Ziele",
                            value: openGoalsCount,
                            systemImage: "circle"
                        )

                        DashboardMetricView(
                            title: "Erledigte Ziele",
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
                        Text("Schnellzugriff")
                            .font(.headline)

                        VStack(spacing: 8) {
                            DashboardNavigationLink(
                                title: "Lernziele öffnen",
                                systemImage: "target"
                            ) {
                                GoalsView()
                            }

                            DashboardNavigationLink(
                                title: "Projekte öffnen",
                                systemImage: "folder"
                            ) {
                                ProjectsView()
                            }

                            DashboardNavigationLink(
                                title: "Bewerbungen öffnen",
                                systemImage: "briefcase"
                            ) {
                                ApplicationsView()
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bewerbungsstatus")
                            .font(.headline)

                        LazyVGrid(columns: metricColumns, spacing: 12) {
                            ForEach(applicationStatusChartData) { statusValue in
                                DashboardStatusView(
                                    title: statusValue.title,
                                    value: statusValue.value
                                )
                            }
                        }
                    }

                    if applicationsCount > 0 {
                        DashboardBarChartView(
                            title: "Bewerbungen nach Status",
                            values: applicationStatusChartData
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct DashboardNavigationLink<Destination: View>: View {
    let title: String
    let systemImage: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Label(title, systemImage: systemImage)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .font(.body)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

private struct DashboardChartValue: Identifiable {
    let title: String
    let value: Int

    var id: String {
        title
    }
}

private struct DashboardBarChartView: View {
    let title: String
    let values: [DashboardChartValue]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Chart(values) { value in
                BarMark(
                    x: .value("Status", value.title),
                    y: .value("Anzahl", value.value)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct DashboardMetricView: View {
    let title: String
    let value: Int
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.title3)
                .fontWeight(.semibold)

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

#Preview {
    DashboardView()
        .modelContainer(for: [LearningGoal.self, PortfolioProject.self, JobApplication.self], inMemory: true)
}
