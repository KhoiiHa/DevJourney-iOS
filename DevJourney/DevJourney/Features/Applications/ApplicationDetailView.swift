//
//  ApplicationDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI

struct ApplicationDetailView: View {
    let application: JobApplication
    @State private var viewModel: ApplicationDetailViewModel

    init(application: JobApplication) {
        self.application = application
        _viewModel = State(initialValue: ApplicationDetailViewModel(application: application))
    }

    var body: some View {
        Form {
            Section("Bewerbung") {
                TextField("Firma", text: $viewModel.companyName)
                TextField("Position", text: $viewModel.positionTitle)

                TextField("Stellenanzeige-Link", text: $viewModel.jobURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
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
            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern") {
                    viewModel.save(to: application)
                }
                .disabled(!viewModel.canSave)
            }
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
