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

    private var hasAnyContent: Bool {
        openGoalsCount > 0 || completedGoalsCount > 0 || projectsCount > 0 || applicationsCount > 0
    }

    private var activeProjectsCount: Int {
        projects.filter { $0.status == PortfolioProjectStatus.inProgress }.count
    }

    private var interviewApplicationsCount: Int {
        applications.filter { $0.status == JobApplicationStatus.interview }.count
    }

    private var focusItems: [DashboardFocusItem] {
        var items: [DashboardFocusItem] = []

        if openGoalsCount > 0 {
            items.append(
                DashboardFocusItem(
                    title: "Offene Lernziele prüfen",
                    subtitle: "Du hast \(openGoalsCount) offene Lernziele.",
                    systemImage: "target"
                )
            )
        }

        if activeProjectsCount > 0 {
            items.append(
                DashboardFocusItem(
                    title: "Aktive Projekte weiterbringen",
                    subtitle: "\(activeProjectsCount) Projekte sind aktuell in Bearbeitung.",
                    systemImage: "folder"
                )
            )
        }

        if interviewApplicationsCount > 0 {
            items.append(
                DashboardFocusItem(
                    title: "Interviews vorbereiten",
                    subtitle: "\(interviewApplicationsCount) Bewerbungen sind im Interview-Status.",
                    systemImage: "person.text.rectangle"
                )
            )
        }

        if items.isEmpty && hasAnyContent {
            items.append(
                DashboardFocusItem(
                    title: "Fortschritt prüfen",
                    subtitle: "Deine Daten sind aktuell ruhig. Nutze den Schnellzugriff für den nächsten Schritt.",
                    systemImage: "checkmark.seal"
                )
            )
        }

        return items
    }

    private var applicationStatusChartData: [DashboardChartValue] {
        JobApplicationStatus.all.map { status in
            DashboardChartValue(
                title: status,
                value: applications.filter { $0.status == status }.count
            )
        }
    }
    
    private func color(forApplicationStatus status: String) -> Color {
        switch status {
        case JobApplicationStatus.applied:
            return .blue
        case JobApplicationStatus.interview:
            return .green
        case JobApplicationStatus.rejected:
            return .red
        default:
            return .secondary
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DevJourney")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Dein persönliches Cockpit für Lernziele, Portfolio-Projekte und Bewerbungen.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(columns: metricColumns, spacing: 12) {
                        DashboardMetricLink(
                            title: "Offene Ziele",
                            value: openGoalsCount,
                            systemImage: "circle"
                        ) {
                            GoalsView()
                        }

                        DashboardMetricLink(
                            title: "Erledigte Ziele",
                            value: completedGoalsCount,
                            systemImage: "checkmark.circle.fill"
                        ) {
                            GoalsView()
                        }

                        DashboardMetricLink(
                            title: "Projekte",
                            value: projectsCount,
                            systemImage: "folder"
                        ) {
                            ProjectsView()
                        }

                        DashboardMetricLink(
                            title: "Bewerbungen",
                            value: applicationsCount,
                            systemImage: "briefcase"
                        ) {
                            ApplicationsView()
                        }
                    }

                    if !hasAnyContent {
                        DashboardFirstRunView()
                    }

                    if hasAnyContent {
                        DashboardFocusSection(items: focusItems)
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

                    if applicationsCount > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bewerbungsstatus")
                                .font(.headline)

                            LazyVGrid(columns: metricColumns, spacing: 12) {
                                ForEach(applicationStatusChartData) { statusValue in
                                    DashboardStatusView(
                                        title: statusValue.title,
                                        value: statusValue.value,
                                        color: color(forApplicationStatus: statusValue.title)
                                    )
                                }
                            }
                        }

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

private struct DashboardFocusItem: Identifiable {
    let title: String
    let subtitle: String
    let systemImage: String

    var id: String {
        title
    }
}

private struct DashboardFocusSection: View {
    let items: [DashboardFocusItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heute im Fokus")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(items) { item in
                    DashboardFocusRow(item: item)
                }
            }
        }
    }
}

private struct DashboardFocusRow: View {
    let item: DashboardFocusItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct DashboardFirstRunView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Erste Schritte")
                .font(.headline)

            VStack(spacing: 8) {
                DashboardNavigationLink(
                    title: "Erstes Lernziel erfassen",
                    systemImage: "target"
                ) {
                    GoalsView()
                }

                DashboardNavigationLink(
                    title: "Erstes Projekt erfassen",
                    systemImage: "folder"
                ) {
                    ProjectsView()
                }

                DashboardNavigationLink(
                    title: "Erste Bewerbung erfassen",
                    systemImage: "briefcase"
                ) {
                    ApplicationsView()
                }
            }
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
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct DashboardStatusView: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(value)")
                .font(.headline)

            StatusBadgeView(title: title, color: color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct DashboardMetricLink<Destination: View>: View {
    let title: String
    let value: Int
    let systemImage: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            DashboardMetricView(
                title: title,
                value: value,
                systemImage: systemImage,
                showsDisclosure: true
            )
        }
        .buttonStyle(.plain)
    }
}

private struct DashboardMetricView: View {
    let title: String
    let value: Int
    let systemImage: String
    let showsDisclosure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: systemImage)

                Spacer()

                if showsDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
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
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [LearningGoal.self, PortfolioProject.self, JobApplication.self], inMemory: true)
}
