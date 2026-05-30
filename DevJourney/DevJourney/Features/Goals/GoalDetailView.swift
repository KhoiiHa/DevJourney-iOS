//
//  GoalDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI

struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let goal: LearningGoal
    @State private var viewModel: GoalDetailViewModel

    init(goal: LearningGoal) {
        self.goal = goal
        _viewModel = State(initialValue: GoalDetailViewModel(goal: goal))
    }

    var body: some View {
        Form {
            Section("Lernziel") {
                TextField("Titel", text: $viewModel.title)

                TextField("Details", text: $viewModel.details, axis: .vertical)
                    .lineLimit(3...8)
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
            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern") {
                    viewModel.save(to: goal)
                    dismiss()
                }
                .disabled(!viewModel.canSave)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: LearningGoal(title: "SwiftData verstehen"))
    }
}
