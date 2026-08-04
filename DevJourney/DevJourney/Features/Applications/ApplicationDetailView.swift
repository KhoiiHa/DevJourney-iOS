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
    @State private var errorMessage: String?

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
                    .autocorrectionDisabled()
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

            Section("Übersicht") {
                StatusBadgeView(
                    title: viewModel.status,
                    color: color(for: viewModel.status)
                )

                if viewModel.hasAppliedDate {
                    Label("Seit \(viewModel.appliedAt, style: .date)", systemImage: "calendar")
                        .foregroundStyle(.secondary)
                }

                if viewModel.validJobURL != nil {
                    Label("Stellenanzeige vorhanden", systemImage: "link")
                        .foregroundStyle(.secondary)
                }
            }

            if let jobURL = viewModel.validJobURL {
                Section("Link") {
                    Link(destination: jobURL) {
                        Label("Stellenanzeige öffnen", systemImage: "link")
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

            Section {
                TextField("Zum Beispiel: Nach Status fragen", text: $viewModel.nextAction)
                    .accessibilityIdentifier("application.detail.next-action")

                Toggle("Follow-up-Datum setzen", isOn: $viewModel.hasFollowUpDate)
                    .accessibilityIdentifier("application.detail.follow-up-toggle")

                if viewModel.hasFollowUpDate {
                    DatePicker(
                        "Follow-up",
                        selection: $viewModel.followUpAt,
                        displayedComponents: .date
                    )
                    .accessibilityIdentifier("application.detail.follow-up-date")
                }
            } header: {
                Text("Nächste Aktion")
            } footer: {
                Text("Ohne Datum bleibt die Aktion offen, wird aber nicht als fällig gezählt.")
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
                    saveApplication()
                }
                .disabled(!viewModel.canSave)
                .accessibilityIdentifier("application.detail.save")
            }
        }
        .confirmationDialog(
            "Bewerbung löschen?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                deleteApplication()
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

    private func saveApplication() {
        viewModel.save(to: application)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = "Die Bewerbung konnte nicht gespeichert werden."
        }
    }

    private func deleteApplication() {
        modelContext.delete(application)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = "Die Bewerbung konnte nicht gelöscht werden."
        }
    }

    private func color(for status: String) -> Color {
        switch status {
        case JobApplicationStatus.applied:
            return .blue
        case JobApplicationStatus.interview:
            return .green
        case JobApplicationStatus.rejected:
            return .red
        default:
            return .secondary
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
