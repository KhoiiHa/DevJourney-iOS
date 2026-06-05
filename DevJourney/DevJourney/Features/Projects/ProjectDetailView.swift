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
    @State private var errorMessage: String?

    init(project: PortfolioProject) {
        self.project = project
        _viewModel = State(initialValue: ProjectDetailViewModel(project: project))
    }

    var body: some View {
        Form {
            Section {
                TextField("Titel", text: $viewModel.title)

                TextField("Kurzbeschreibung", text: $viewModel.summary, axis: .vertical)
                    .lineLimit(2...6)

                TextField("GitHub-Link", text: $viewModel.githubURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
            } header: {
                Text("Projekt")
            } footer: {
                if let validationMessage = viewModel.validationMessage {
                    Text(validationMessage)
                        .foregroundStyle(.secondary)
                }
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
            
            if let githubURL = viewModel.validGitHubURL {
                Section("Link") {
                    Link(destination: githubURL) {
                        Label("GitHub öffnen", systemImage: "link")
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
                    saveProject()
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
                deleteProject()
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
        .alert("Aktion fehlgeschlagen", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Bitte versuche es erneut.")
        }
    }

    private func saveProject() {
        viewModel.save(to: project)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = "Das Projekt konnte nicht gespeichert werden."
        }
    }

    private func deleteProject() {
        modelContext.delete(project)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = "Das Projekt konnte nicht gelöscht werden."
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: PortfolioProject(title: "DevJourney"))
    }
}
