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

    private var openGoalsCount: Int {
        goals.filter { !$0.isCompleted }.count
    }

    private var completedGoalsCount: Int {
        goals.filter(\.isCompleted).count
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

                HStack(spacing: 12) {
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
                }

                NavigationLink {
                    GoalsView()
                } label: {
                    Label("Lernziele öffnen", systemImage: "target")
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Dashboard")
        }
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
        .modelContainer(for: LearningGoal.self, inMemory: true)
}
