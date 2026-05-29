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
                VStack(alignment: .leading, spacing: 16) {
                    Text("DevJourney")
                        .font(.largeTitle)
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Schnellzugriff")
                            .font(.headline)

                        VStack(spacing: 10) {
                            DashboardNavigationLink(
                                title: "Lernziele öffnen",
                                systemImage: "target"
                            ) {
                                GoalsView()
                            }
                            .buttonStyle(.borderedProminent)

                            DashboardNavigationLink(
                                title: "Projekte öffnen",
                                systemImage: "folder"
                            ) {
                                ProjectsView()
                            }
                            .buttonStyle(.bordered)

                            DashboardNavigationLink(
                                title: "Bewerbungen öffnen",
                                systemImage: "briefcase"
                            ) {
                                ApplicationsView()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Dashboard")
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
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
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
