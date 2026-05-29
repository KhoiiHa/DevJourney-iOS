//
//  ApplicationsView.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import SwiftData
import SwiftUI

struct ApplicationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JobApplication.createdAt, order: .reverse) private var applications: [JobApplication]
    @State private var viewModel = ApplicationsViewModel()

    var body: some View {
        List {
            if applications.isEmpty {
                ContentUnavailableView(
                    "Noch keine Bewerbungen",
                    systemImage: "briefcase",
                    description: Text("Lege deine erste Bewerbung an, um deinen Prozess zu verfolgen.")
                )
            } else {
                ForEach(applications) { application in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(application.positionTitle)
                            .font(.headline)

                        Text(application.companyName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            Text(application.status)

                            if let appliedAt = application.appliedAt {
                                Text("Seit \(appliedAt, style: .date)")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    viewModel.deleteApplications(at: offsets, from: applications, using: modelContext)
                }
            }
        }
        .navigationTitle("Bewerbungen")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.startAddingApplication()
                } label: {
                    Label("Bewerbung hinzufügen", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddApplication, onDismiss: {
            viewModel.cancelAddingApplication()
        }) {
            NavigationStack {
                Form {
                    Section("Bewerbung") {
                        TextField("Firma", text: $viewModel.companyName)
                        TextField("Position", text: $viewModel.positionTitle)
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
                .navigationTitle("Neue Bewerbung")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            viewModel.cancelAddingApplication()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Speichern") {
                            viewModel.addApplication(using: modelContext)
                        }
                        .disabled(!viewModel.canAddApplication)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ApplicationsView()
    }
    .modelContainer(for: JobApplication.self, inMemory: true)
}
