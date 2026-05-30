//
//  ProjectDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let project: PortfolioProject
    @State private var viewModel: ProjectDetailViewModel
    @State private var isShowingDeleteConfirmation = false

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
            ToolbarItem(placement: .destructiveAction) {
                Button("Löschen", role: .destructive) {
                    isShowingDeleteConfirmation = true
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern") {
                    viewModel.save(to: project)
                    dismiss()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .confirmationDialog(
            "Projekt löschen?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                modelContext.delete(project)
                dismiss()
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: PortfolioProject(title: "DevJourney"))
    }
}
