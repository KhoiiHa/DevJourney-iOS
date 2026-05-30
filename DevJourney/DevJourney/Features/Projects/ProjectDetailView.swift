//
//  ProjectDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: PortfolioProject
    @State private var viewModel: ProjectDetailViewModel

    init(project: PortfolioProject) {
        self.project = project
        _viewModel = State(initialValue: ProjectDetailViewModel(project: project))
    }

    var body: some View {
        Form {
            Section("Projekt") {
                TextField("Titel", text: $viewModel.title)

                TextField("Kurzbeschreibung", text: $viewModel.summary, axis: .vertical)
                    .lineLimit(2...6)

                TextField("GitHub-Link", text: $viewModel.githubURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }

            Section("Notizen") {
                TextField("Was hast du gebaut oder gelernt?", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section("Status") {
                Picker("Status", selection: $viewModel.status) {
                    ForEach(viewModel.availableStatuses, id: \.self) { status in
                        Text(status)
                    }
                }
            }
        }
        .navigationTitle("Projekt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern") {
                    viewModel.save(to: project)
                }
                .disabled(!viewModel.canSave)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: PortfolioProject(title: "DevJourney"))
    }
}
