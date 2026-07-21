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
    @State private var editMode: EditMode = .inactive

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

            Section {
                if viewModel.orderedMilestones(for: project).isEmpty {
                    Text("Noch keine Meilensteine")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.orderedMilestones(for: project)) { milestone in
                        HStack(spacing: 12) {
                            Button {
                                toggleMilestone(milestone)
                            } label: {
                                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(
                                        milestone.isCompleted ? Color.green : Color.secondary
                                    )
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(
                                milestone.isCompleted ? "Als offen markieren" : "Als erledigt markieren"
                            )

                            Text(milestone.title)
                                .strikethrough(milestone.isCompleted)
                                .foregroundStyle(milestone.isCompleted ? .secondary : .primary)

                            Spacer()

                            Button {
                                viewModel.startEditingMilestone(milestone)
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Meilenstein bearbeiten")
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteMilestone(milestone)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                    .onMove(perform: moveMilestones)
                }

                Button {
                    viewModel.startAddingMilestone()
                } label: {
                    Label("Meilenstein hinzufügen", systemImage: "plus")
                }

                if project.milestones.count > 1 {
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Label(
                            editMode == .active ? "Sortieren beenden" : "Reihenfolge ändern",
                            systemImage: editMode == .active
                                ? "checkmark"
                                : "arrow.up.arrow.down"
                        )
                    }
                }
            } header: {
                Text("Meilensteine")
            }

            Section {
                HStack {
                    Text("Fortschritt")
                    Spacer()
                    Text(viewModel.readinessProgressText(for: project))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: viewModel.readinessProgress(for: project))

                ForEach(PortfolioReadinessRequirement.allCases) { requirement in
                    Toggle(
                        requirement.title,
                        isOn: Binding(
                            get: {
                                viewModel.isReadinessRequirementCompleted(
                                    requirement,
                                    for: project
                                )
                            },
                            set: { isCompleted in
                                updateReadinessRequirement(
                                    requirement,
                                    isCompleted: isCompleted
                                )
                            }
                        )
                    )
                }
            } header: {
                Text("Portfolio-Readiness")
            } footer: {
                if let nextStep = viewModel.nextOpenStepTitle(for: project) {
                    Label("Als Nächstes: \(nextStep)", systemImage: "arrow.forward.circle")
                } else {
                    Label("Portfolio-bereit", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
            }

            Section("Übersicht") {
                StatusBadgeView(
                    title: viewModel.status,
                    color: color(for: viewModel.status)
                )

                if viewModel.validGitHubURL != nil {
                    Label("GitHub-Link vorhanden", systemImage: "link")
                        .foregroundStyle(.secondary)
                }

                if viewModel.hasNotes {
                    Label("Notizen vorhanden", systemImage: "note.text")
                        .foregroundStyle(.secondary)
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
        .environment(\.editMode, $editMode)
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
        .alert(
            viewModel.milestoneEditorTitle,
            isPresented: $viewModel.isShowingMilestoneEditor
        ) {
            TextField("Titel", text: $viewModel.milestoneTitle)

            Button("Abbrechen", role: .cancel) {
                viewModel.cancelMilestoneEditing()
            }

            Button("Speichern") {
                saveMilestone()
            }
            .disabled(!viewModel.canSaveMilestone)
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

    private func saveMilestone() {
        do {
            try viewModel.saveMilestone(to: project, using: modelContext)
        } catch {
            errorMessage = "Der Meilenstein konnte nicht gespeichert werden."
        }
    }

    private func toggleMilestone(_ milestone: ProjectMilestone) {
        do {
            try viewModel.toggleMilestone(milestone, using: modelContext)
        } catch {
            errorMessage = "Der Meilenstein konnte nicht aktualisiert werden."
        }
    }

    private func moveMilestones(from source: IndexSet, to destination: Int) {
        do {
            try viewModel.moveMilestones(
                fromOffsets: source,
                toOffset: destination,
                in: project,
                using: modelContext
            )
        } catch {
            errorMessage = "Die Reihenfolge konnte nicht gespeichert werden."
        }
    }

    private func deleteMilestone(_ milestone: ProjectMilestone) {
        do {
            try viewModel.deleteMilestone(milestone, using: modelContext)
        } catch {
            errorMessage = "Der Meilenstein konnte nicht gelöscht werden."
        }
    }

    private func updateReadinessRequirement(
        _ requirement: PortfolioReadinessRequirement,
        isCompleted: Bool
    ) {
        do {
            try viewModel.setReadinessRequirement(
                requirement,
                isCompleted: isCompleted,
                for: project,
                using: modelContext
            )
        } catch {
            errorMessage = "Die Readiness-Checkliste konnte nicht aktualisiert werden."
        }
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
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: PortfolioProject(title: "DevJourney"))
    }
    .modelContainer(
        for: [PortfolioProject.self, ProjectMilestone.self],
        inMemory: true
    )
}
