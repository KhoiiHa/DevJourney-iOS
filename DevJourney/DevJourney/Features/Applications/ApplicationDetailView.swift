//
//  ApplicationDetailView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftUI

struct ApplicationDetailView: View {
    @Bindable var application: JobApplication

    private let availableStatuses = JobApplicationStatus.all

    var body: some View {
        Form {
            Section("Bewerbung") {
                TextField("Firma", text: $application.companyName)
                TextField("Position", text: $application.positionTitle)

                TextField("Stellenanzeige-Link", text: $application.jobURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }

            Section("Status") {
                Picker("Status", selection: $application.status) {
                    ForEach(availableStatuses, id: \.self) { status in
                        Text(status)
                    }
                }
            }

            Section("Bewerbungsdatum") {
                if application.appliedAt == nil {
                    Button("Datum setzen") {
                        application.appliedAt = Date()
                    }
                } else {
                    DatePicker(
                        "Datum",
                        selection: appliedAtBinding,
                        displayedComponents: .date
                    )

                    Button("Datum entfernen", role: .destructive) {
                        application.appliedAt = nil
                    }
                }
            }
        }
        .navigationTitle("Bewerbung")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appliedAtBinding: Binding<Date> {
        Binding {
            application.appliedAt ?? Date()
        } set: { newValue in
            application.appliedAt = newValue
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
