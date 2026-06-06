//
//  GoalDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let goal: LearningGoal
    @State private var viewModel: GoalDetailViewModel
    @State private var isShowingDeleteConfirmation = false
    @State private var errorMessage: String?

    init(goal: LearningGoal) {
        self.goal = goal
        _viewModel = State(initialValue: GoalDetailViewModel(goal: goal))
    }

    var body: some View {
        Form {
            Section {
                TextField("Titel", text: $viewModel.title)

                TextField("Details", text: $viewModel.details, axis: .vertical)
                    .lineLimit(3...8)
                    .submitLabel(.done)
            } header: {
                Text("Lernziel")
            } footer: {
                if let validationMessage = viewModel.validationMessage {
                    Text(validationMessage)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Status") {
                Toggle("Erledigt", isOn: $viewModel.isCompleted)
            }

            Section("Übersicht") {
                StatusBadgeView(
                    title: viewModel.isCompleted ? "Erledigt" : "Offen",
                    color: viewModel.isCompleted ? .green : .secondary
                )

                if viewModel.hasTargetDate {
                    Label("Ziel: \(viewModel.targetDate, style: .date)", systemImage: "calendar")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Zieldatum") {
                Toggle("Zieldatum setzen", isOn: $viewModel.hasTargetDate)

                if viewModel.hasTargetDate {
                    DatePicker(
                        "Datum",
                        selection: $viewModel.targetDate,
                        displayedComponents: .date
                    )
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Löschen", role: .destructive) {
                    isShowingDeleteConfirmation = true
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern") {
                    saveGoal()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .confirmationDialog(
            "Lernziel löschen?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                deleteGoal()
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

    private func saveGoal() {
        viewModel.save(to: goal)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = "Das Lernziel konnte nicht gespeichert werden."
        }
    }

    private func deleteGoal() {
        modelContext.delete(goal)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = "Das Lernziel konnte nicht gelöscht werden."
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: LearningGoal(title: "SwiftData verstehen"))
    }
}
