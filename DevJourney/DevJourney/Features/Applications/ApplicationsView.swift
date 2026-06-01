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
    @State private var errorMessage: String?
    @State private var searchText = ""
    @FocusState private var isCompanyFieldFocused: Bool

    private var sortedApplications: [JobApplication] {
        applications.sorted { firstApplication, secondApplication in
            let firstPriority = priority(for: firstApplication.status)
            let secondPriority = priority(for: secondApplication.status)

            if firstPriority == secondPriority {
                return firstApplication.createdAt > secondApplication.createdAt
            }

            return firstPriority < secondPriority
        }
    }

    private var filteredApplications: [JobApplication] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sortedApplications
        }

        return sortedApplications.filter { application in
            application.companyName.localizedStandardContains(searchText) ||
            application.positionTitle.localizedStandardContains(searchText) ||
            application.jobURL.localizedStandardContains(searchText)
        }
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        List {
            if applications.isEmpty {
                ContentUnavailableView {
                    Label("Noch keine Bewerbungen", systemImage: "briefcase")
                } description: {
                    Text("Lege deine erste Bewerbung an, um deinen Prozess zu verfolgen.")
                } actions: {
                    Button("Erste Bewerbung erfassen") {
                        viewModel.startAddingApplication()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if isSearching && filteredApplications.isEmpty {
                ContentUnavailableView {
                    Label("Keine passenden Bewerbungen", systemImage: "magnifyingglass")
                } description: {
                    Text("Passe deinen Suchbegriff an oder lege eine neue Bewerbung an.")
                }
            } else {
                ForEach(viewModel.availableStatuses, id: \.self) { status in
                    let applicationsForStatus = filteredApplications.filter { $0.status == status }

                    if !applicationsForStatus.isEmpty {
                        Section(status) {
                            ForEach(applicationsForStatus) { application in
                                applicationRow(for: application)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteApplication(application)
                                        } label: {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Bewerbungen")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Bewerbungen suchen")
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
                    Section {
                        TextField("Firma", text: $viewModel.companyName)
                            .focused($isCompanyFieldFocused)
                            .submitLabel(.next)

                        TextField("Position", text: $viewModel.positionTitle)
                            .submitLabel(.next)

                        TextField("Stellenanzeige-Link", text: $viewModel.jobURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .submitLabel(.done)
                            .onSubmit {
                                if viewModel.canAddApplication {
                                    addApplication()
                                }
                            }
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
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            viewModel.cancelAddingApplication()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Speichern") {
                            addApplication()
                        }
                        .disabled(!viewModel.canAddApplication)
                    }
                }
                .onAppear {
                    isCompanyFieldFocused = true
                }
            }
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

    private func addApplication() {
        do {
            try viewModel.addApplication(using: modelContext)
            isCompanyFieldFocused = false
        } catch {
            errorMessage = "Die Bewerbung konnte nicht erstellt werden."
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

    private func priority(for status: String) -> Int {
        switch status {
        case JobApplicationStatus.interview:
            return 0
        case JobApplicationStatus.applied:
            return 1
        case JobApplicationStatus.rejected:
            return 3
        default:
            return 2
        }
    }

    private func applicationRow(for application: JobApplication) -> some View {
        NavigationLink {
            ApplicationDetailView(application: application)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(application.positionTitle)
                    .font(.headline)

                Text(application.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                StatusBadgeView(
                    title: application.status,
                    color: color(for: application.status)
                )

                if !application.jobURL.isEmpty || application.appliedAt != nil {
                    HStack(spacing: 8) {
                        if !application.jobURL.isEmpty {
                            Label("Stellenanzeige", systemImage: "link")
                        }

                        if let appliedAt = application.appliedAt {
                            Label("Seit \(appliedAt, style: .date)", systemImage: "calendar")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func deleteApplication(_ application: JobApplication) {
        modelContext.delete(application)

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Die Bewerbung konnte nicht gelöscht werden."
        }
    }
}

#Preview {
    NavigationStack {
        ApplicationsView()
    }
    .modelContainer(for: JobApplication.self, inMemory: true)
}
