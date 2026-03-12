import SwiftUI

struct MedicationsView: View {
    @State private var viewModel = MedicationsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading medications...")
                } else if let error = viewModel.error {
                    errorView(error)
                } else if viewModel.medications.isEmpty {
                    emptyStateView
                } else {
                    medicationsList
                }
            }
            .navigationTitle("Medications")
            .task {
                await viewModel.loadMedications()
            }
            .refreshable {
                await viewModel.loadMedications()
            }
        }
    }
    
    @ViewBuilder
    private var medicationsList: some View {
        List(viewModel.medications) { medication in
            VStack(alignment: .leading, spacing: 8) {
                Text(medication.name)
                    .font(.headline)
                
                if let dose = medication.dose {
                    Label(dose, systemImage: "pills")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let frequency = medication.frequency {
                    Label(frequency, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                if let startDate = medication.startDate {
                    Label("Since \(startDate.formatted(date: .abbreviated, time: .omitted))", 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 4)
        }
        .listStyle(.insetGrouped)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Medications", systemImage: "pills")
        } description: {
            Text("Add medications in the Apple Health app to see them here.")
        } actions: {
            Button("Open Health App") {
                if let url = URL(string: "x-apple-health://") {
                }
            }
        }
    }
    
    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        }
    }
}

#Preview {
    MedicationsView()
}