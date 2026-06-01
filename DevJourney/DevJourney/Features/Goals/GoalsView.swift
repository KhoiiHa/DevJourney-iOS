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

    private var openGoals: [LearningGoal] {
        goals.filter { !$0.isCompleted }
    }

    private var completedGoals: [LearningGoal] {
        goals.filter(\.isCompleted)
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
            } else {
                if !openGoals.isEmpty {
                    Section("Offen") {
                        ForEach(openGoals) { goal in
                            goalRow(for: goal)
                        }
                        .onDelete { offsets in
                            viewModel.deleteGoals(at: offsets, from: openGoals, using: modelContext)
                        }
                    }
                }

                if !completedGoals.isEmpty {
                    Section("Erledigt") {
                        ForEach(completedGoals) { goal in
                            goalRow(for: goal)
                        }
                        .onDelete { offsets in
                            viewModel.deleteGoals(at: offsets, from: completedGoals, using: modelContext)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Lernziele")
        .navigationBarTitleDisplayMode(.inline)
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
                            viewModel.addGoal(using: modelContext)
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
                        GoalStatusBadge(isCompleted: goal.isCompleted)

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

private struct GoalStatusBadge: View {
    let isCompleted: Bool

    var body: some View {
        Text(isCompleted ? "Erledigt" : "Offen")
            .font(.caption.weight(.medium))
            .foregroundStyle(isCompleted ? .green : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(isCompleted ? Color.green.opacity(0.12) : Color.secondary.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        GoalsView()
    }
    .modelContainer(for: LearningGoal.self, inMemory: true)
}
