//
//  GoalDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI

struct GoalDetailView: View {
    @Bindable var goal: LearningGoal

    var body: some View {
        Form {
            Section("Lernziel") {
                TextField("Titel", text: $goal.title)

                TextField("Details", text: $goal.details, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section("Status") {
                Toggle("Erledigt", isOn: $goal.isCompleted)
            }

            Section("Zieldatum") {
                Toggle("Zieldatum setzen", isOn: hasTargetDate)

                if let targetDate = goal.targetDate {
                    DatePicker(
                        "Datum",
                        selection: targetDateBinding(defaultDate: targetDate),
                        displayedComponents: .date
                    )
                }
            }
        }
        .navigationTitle("Details")
    }

    private var hasTargetDate: Binding<Bool> {
        Binding(
            get: {
                goal.targetDate != nil
            },
            set: { isEnabled in
                goal.targetDate = isEnabled ? Date() : nil
            }
        )
    }

    private func targetDateBinding(defaultDate: Date) -> Binding<Date> {
        Binding(
            get: {
                goal.targetDate ?? defaultDate
            },
            set: { newDate in
                goal.targetDate = newDate
            }
        )
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: LearningGoal(title: "SwiftData verstehen"))
    }
}
