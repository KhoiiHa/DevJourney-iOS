//
//  ApplicationDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI
import SwiftData

struct ApplicationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let application: JobApplication
    @State private var viewModel: ApplicationDetailViewModel
    @State private var isShowingDeleteConfirmation = false

    init(application: JobApplication) {
        self.application = application
        _viewModel = State(initialValue: ApplicationDetailViewModel(application: application))
    }

    var body: some View {
        Form {
            Section {
                TextField("Firma", text: $viewModel.companyName)
                TextField("Position", text: $viewModel.positionTitle)

                TextField("Stellenanzeige-Link", text: $viewModel.jobURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            } header: {
                Text("Bewerbung")
            } footer: {
                if let validationMessage = viewModel.validationMessage {
                    Text(validationMessage)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Status") {
                Picker("Status", selection: $viewModel.status) {
                    ForEach(viewModel.availableStatuses, id: \.self) { status in
                        Text(status)
                    }
                }
            }

            Section("Bewerbungsdatum") {
                Toggle("Datum setzen", isOn: $viewModel.hasAppliedDate)

                if viewModel.hasAppliedDate {
                    DatePicker(
                        "Datum",
                        selection: $viewModel.appliedAt,
                        displayedComponents: .date
                    )
                }
            }
        }
        .navigationTitle("Bewerbung")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Löschen", role: .destructive) {
                    isShowingDeleteConfirmation = true
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern") {
                    viewModel.save(to: application)
                    dismiss()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .confirmationDialog(
            "Bewerbung löschen?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                modelContext.delete(application)
                dismiss()
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
}

#Preview {
    NavigationStack {
        ApplicationDetailView(
            application: JobApplication(
                companyName: "Apple",
                positionTitle: "iOS Developer",
                status: JobApplicationStatus.applied,
                appliedAt: Date()
            )
        )
    }
}
