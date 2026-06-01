//
//  ProjectsView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftData
import SwiftUI

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PortfolioProject.createdAt, order: .reverse) private var projects: [PortfolioProject]
    @State private var viewModel = ProjectsViewModel()
    @State private var errorMessage: String?

    var body: some View {
        List {
            if projects.isEmpty {
                ContentUnavailableView {
                    Label("Noch keine Portfolio-Projekte", systemImage: "folder")
                } description: {
                    Text("Lege dein erstes Projekt an, um deine Arbeit sichtbar zu machen.")
                } actions: {
                    Button("Erstes Projekt erfassen") {
                        viewModel.startAddingProject()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ForEach(projects) { project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(project.title)
                                .font(.headline)

                            if !project.summary.isEmpty {
                                Text(project.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 8) {
                                ProjectStatusBadge(status: project.status)

                                if !project.githubURL.isEmpty {
                                    Label("GitHub", systemImage: "link")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteProject(project)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Projekte")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.startAddingProject()
                } label: {
                    Label("Projekt hinzufügen", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddProject, onDismiss: {
            viewModel.cancelAddingProject()
        }) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Titel", text: $viewModel.newProjectTitle)

                        TextField("Kurzbeschreibung", text: $viewModel.newProjectSummary, axis: .vertical)
                            .lineLimit(2...5)

                        TextField("GitHub-Link", text: $viewModel.newProjectGitHubURL)
                            .textInputAutocapitalization(.never)
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
                        TextField("Was hast du gebaut oder gelernt?", text: $viewModel.newProjectNotes, axis: .vertical)
                            .lineLimit(3...8)
                    }

                    Section("Status") {
                        Picker("Status", selection: $viewModel.newProjectStatus) {
                            ForEach(viewModel.availableStatuses, id: \.self) { status in
                                Text(status)
                            }
                        }
                    }
                }
                .navigationTitle("Neues Projekt")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            viewModel.cancelAddingProject()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Speichern") {
                            viewModel.addProject(using: modelContext)
                        }
                        .disabled(!viewModel.canAddProject)
                    }
                }
            }
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

    private func deleteProject(_ project: PortfolioProject) {
        modelContext.delete(project)

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Das Projekt konnte nicht gelöscht werden."
        }
    }
}

private struct ProjectStatusBadge: View {
    let status: String

    private var tint: Color {
        switch status {
        case PortfolioProjectStatus.inProgress:
            return .blue
        case PortfolioProjectStatus.completed:
            return .green
        default:
            return .secondary
        }
    }

    var body: some View {
        Text(status)
            .font(.caption.weight(.medium))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        ProjectsView()
    }
    .modelContainer(for: PortfolioProject.self, inMemory: true)
}
