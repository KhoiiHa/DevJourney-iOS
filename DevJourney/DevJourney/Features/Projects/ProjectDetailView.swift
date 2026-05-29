//
//  ProjectDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI

struct ProjectDetailView: View {
    @Bindable var project: PortfolioProject

    private let availableStatuses = ["Geplant", "In Arbeit", "Abgeschlossen"]

    var body: some View {
        Form {
            Section("Projekt") {
                TextField("Titel", text: $project.title)

                TextField("Kurzbeschreibung", text: $project.summary, axis: .vertical)
                    .lineLimit(2...6)
            }

            Section("Status") {
                Picker("Status", selection: $project.status) {
                    ForEach(availableStatuses, id: \.self) { status in
                        Text(status)
                    }
                }
            }
        }
        .navigationTitle("Projekt")
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: PortfolioProject(title: "DevJourney"))
    }
}
