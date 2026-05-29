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
        }
        .navigationTitle("Details")
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: LearningGoal(title: "SwiftData verstehen"))
    }
}
