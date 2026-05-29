//
//  DashboardView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("DevJourney")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Lernziele, Portfolio-Projekte und Bewerbungen an einem Ort.")
                    .font(.body)
                    .foregroundStyle(.secondary)

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

#Preview {
    DashboardView()
        .modelContainer(for: LearningGoal.self, inMemory: true)
}
