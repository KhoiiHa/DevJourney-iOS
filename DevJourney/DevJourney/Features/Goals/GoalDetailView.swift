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
                    viewModel.save(to: goal)
                    try? modelContext.save()
                    dismiss()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .onChange(of: viewModel.isCompleted) { _, _ in
            viewModel.updateCompletion(on: goal)
            try? modelContext.save()
        }
        .confirmationDialog(
            "Lernziel löschen?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                modelContext.delete(goal)
                dismiss()
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: LearningGoal(title: "SwiftData verstehen"))
    }
}
