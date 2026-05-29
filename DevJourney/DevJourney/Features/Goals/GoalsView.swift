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

    var body: some View {
        List {
            if goals.isEmpty {
                ContentUnavailableView(
                    "Noch keine Lernziele",
                    systemImage: "target",
                    description: Text("Lege dein erstes Lernziel an, um deinen Fortschritt sichtbar zu machen.")
                )
            } else {
                ForEach(goals) { goal in
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
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    viewModel.deleteGoals(at: offsets, from: goals, using: modelContext)
                }
            }
        }
        .navigationTitle("Lernziele")
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
}

#Preview {
    NavigationStack {
        GoalsView()
    }
    .modelContainer(for: LearningGoal.self, inMemory: true)
}
