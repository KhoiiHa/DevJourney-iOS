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

    private var openGoals: [LearningGoal] {
        goals.filter { !$0.isCompleted }
    }

    private var completedGoals: [LearningGoal] {
        goals.filter(\.isCompleted)
    }

    var body: some View {
        List {
            if goals.isEmpty {
                ContentUnavailableView(
                    "Noch keine Lernziele",
                    systemImage: "target",
                    description: Text("Lege dein erstes Lernziel an, um deinen Fortschritt sichtbar zu machen.")
                )
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
                    TextField("Titel", text: $viewModel.newGoalTitle)
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
    }

    private func goalRow(for goal: LearningGoal) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.toggleCompletion(for: goal)
            } label: {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(goal.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            NavigationLink {
                GoalDetailView(goal: goal)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .strikethrough(goal.isCompleted)
                        .foregroundStyle(goal.isCompleted ? .secondary : .primary)

                    Text(goal.isCompleted ? "Erledigt" : "Offen")
                        .font(.caption)
                        .foregroundStyle(goal.isCompleted ? .green : .secondary)

                    if let targetDate = goal.targetDate {
                        Text("Ziel: \(targetDate, style: .date)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        GoalsView()
    }
    .modelContainer(for: LearningGoal.self, inMemory: true)
}
