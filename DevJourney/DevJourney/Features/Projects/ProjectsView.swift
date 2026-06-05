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
    @State private var searchText = ""
    @FocusState private var isTitleFieldFocused: Bool

    private var sortedProjects: [PortfolioProject] {
        projects.sorted { firstProject, secondProject in
            let firstPriority = priority(for: firstProject.status)
            let secondPriority = priority(for: secondProject.status)

            if firstPriority == secondPriority {
                return firstProject.createdAt > secondProject.createdAt
            }

            return firstPriority < secondPriority
        }
    }

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
            } else if isSearching && filteredProjects.isEmpty {
                ContentUnavailableView {
                    Label("Keine passenden Projekte", systemImage: "magnifyingglass")
                } description: {
                    Text("Passe deinen Suchbegriff an oder lege ein neues Projekt an.")
                }
            } else {
                ForEach(filteredProjects) { project in
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
                                StatusBadgeView(
                                    title: project.status,
                                    color: color(for: project.status)
                                )

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
        .searchable(text: $searchText, prompt: "Projekte suchen")
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
                            .focused($isTitleFieldFocused)
                            .submitLabel(.next)

                        TextField("Kurzbeschreibung", text: $viewModel.newProjectSummary, axis: .vertical)
                            .lineLimit(2...5)

                        TextField("GitHub-Link", text: $viewModel.newProjectGitHubURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .submitLabel(.done)
                            .onSubmit {
                                if viewModel.canAddProject {
                                    addProject()
                                }
                            }
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
                            addProject()
                        }
                        .disabled(!viewModel.canAddProject)
                    }
                }
                .onAppear {
                    isTitleFieldFocused = true
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

    private var filteredProjects: [PortfolioProject] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sortedProjects
        }

        return sortedProjects.filter { project in
            project.title.localizedStandardContains(searchText) ||
            project.summary.localizedStandardContains(searchText) ||
            project.githubURL.localizedStandardContains(searchText)
        }
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func color(for status: String) -> Color {
        switch status {
        case PortfolioProjectStatus.inProgress:
            return .blue
        case PortfolioProjectStatus.completed:
            return .green
        default:
            return .secondary
        }
    }

    private func priority(for status: String) -> Int {
        switch status {
        case PortfolioProjectStatus.inProgress:
            return 0
        case PortfolioProjectStatus.completed:
            return 2
        default:
            return 1
        }
    }

    private func addProject() {
        do {
            try viewModel.addProject(using: modelContext)
            isTitleFieldFocused = false
        } catch {
            errorMessage = "Das Projekt konnte nicht erstellt werden."
        }
    }

    private func deleteProject(_ project: PortfolioProject) {
        modelContext.delete(project)

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = "Das Projekt konnte nicht gelöscht werden."
        }
    }
}

#Preview {
    NavigationStack {
        ProjectsView()
    }
    .modelContainer(for: PortfolioProject.self, inMemory: true)
}
