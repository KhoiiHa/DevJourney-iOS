//
//  DashboardView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

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
}
