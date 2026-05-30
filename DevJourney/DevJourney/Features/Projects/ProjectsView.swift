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

    var body: some View {
        List {
            if projects.isEmpty {
                ContentUnavailableView(
                    "Noch keine Portfolio-Projekte",
                    systemImage: "folder",
                    description: Text("Lege dein erstes Projekt an, um deine Arbeit sichtbar zu machen.")
                )
            } else {
                ForEach(projects) { project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.title)
                                .font(.headline)

                            if !project.summary.isEmpty {
                                Text(project.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if !project.githubURL.isEmpty {
                                Label("GitHub", systemImage: "link")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text(project.status)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { offsets in
                    viewModel.deleteProjects(at: offsets, from: projects, using: modelContext)
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
                    Section("Projekt") {
                        TextField("Titel", text: $viewModel.newProjectTitle)

                        TextField("Kurzbeschreibung", text: $viewModel.newProjectSummary, axis: .vertical)
                            .lineLimit(2...5)

                        TextField("GitHub-Link", text: $viewModel.newProjectGitHubURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
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
    }
}

#Preview {
    NavigationStack {
        ProjectsView()
    }
    .modelContainer(for: PortfolioProject.self, inMemory: true)
}
