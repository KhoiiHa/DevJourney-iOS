//
//  GoalsView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftData
import SwiftUI

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LearningGoal.createdAt, order: .reverse) private var goals: [LearningGoal]
    @State private var viewModel = GoalsViewModel()
    @State private var errorMessage: String?
    @State private var searchText = ""

    private var sortedGoals: [LearningGoal] {
        goals.sorted { firstGoal, secondGoal in
            firstGoal.createdAt > secondGoal.createdAt
        }
    }

    private var filteredGoals: [LearningGoal] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sortedGoals
        }

        return sortedGoals.filter { goal in
            goal.title.localizedStandardContains(searchText)
        }
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var openGoals: [LearningGoal] {
        filteredGoals.filter { !$0.isCompleted }
    }

    private var completedGoals: [LearningGoal] {
        filteredGoals.filter(\.isCompleted)
    }

    var body: some View {
        List {
            if goals.isEmpty {
                ContentUnavailableView {
                    Label("Noch keine Lernziele", systemImage: "target")
                } description: {
                    Text("Lege dein erstes Lernziel an, um deinen Fortschritt sichtbar zu machen.")
                } actions: {
                    Button("Erstes Lernziel erfassen") {
                        viewModel.startAddingGoal()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if isSearching && filteredGoals.isEmpty {
                ContentUnavailableView {
                    Label("Keine passenden Lernziele", systemImage: "magnifyingglass")
                } description: {
                    Text("Passe deinen Suchbegriff an oder lege ein neues Lernziel an.")
                }
            } else {
                if !openGoals.isEmpty {
                    Section("Offen") {
                        ForEach(openGoals) { goal in
                            goalRow(for: goal)
                        }
                    }
                }

                if !completedGoals.isEmpty {
                    Section("Erledigt") {
                        ForEach(completedGoals) { goal in
                            goalRow(for: goal)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Lernziele")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Lernziele suchen")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.startAddingGoal()
                } label: {
                    Label("Lernziel hinzufügen", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddGoal, onDismiss: {
            viewModel.cancelAddingGoal()
        }) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Titel", text: $viewModel.newGoalTitle)
                    } footer: {
                        if let validationMessage = viewModel.validationMessage {
                            Text(validationMessage)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .navigationTitle("Neues Lernziel")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            viewModel.cancelAddingGoal()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Speichern") {
                            addGoal()
                        }
                        .disabled(!viewModel.canAddGoal)
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

    private func addGoal() {
        do {
            try viewModel.addGoal(using: modelContext)
        } catch {
            errorMessage = "Das Lernziel konnte nicht erstellt werden."
        }
    }

    private func goalRow(for goal: LearningGoal) -> some View {
        HStack(spacing: 12) {
            Button {
                toggleGoalCompletion(goal)
            } label: {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(goal.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            NavigationLink {
                GoalDetailView(goal: goal)
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(goal.title)
                        .font(.headline)
                        .strikethrough(goal.isCompleted)
                        .foregroundStyle(goal.isCompleted ? .secondary : .primary)

                    HStack(spacing: 8) {
                        StatusBadgeView(
                            title: goal.isCompleted ? "Erledigt" : "Offen",
                            color: goal.isCompleted ? .green : .secondary
                        )

                        if let targetDate = goal.targetDate {
                            Label("Ziel: \(targetDate, style: .date)", systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteGoal(goal)
            } label: {
                Label("Löschen", systemImage: "trash")
            }

            Button {
                toggleGoalCompletion(goal)
            } label: {
                Label(
                    goal.isCompleted ? "Wieder öffnen" : "Erledigt",
                    systemImage: goal.isCompleted ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(goal.isCompleted ? .orange : .green)
        }
    }

    private func toggleGoalCompletion(_ goal: LearningGoal) {
        viewModel.toggleCompletion(for: goal)

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Der Lernziel-Status konnte nicht gespeichert werden."
        }
    }

    private func deleteGoal(_ goal: LearningGoal) {
        modelContext.delete(goal)

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Das Lernziel konnte nicht gelöscht werden."
        }
    }
}

#Preview {
    NavigationStack {
        GoalsView()
    }
    .modelContainer(for: LearningGoal.self, inMemory: true)
}
