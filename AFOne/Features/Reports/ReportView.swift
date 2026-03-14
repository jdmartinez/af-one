import SwiftUI

/// ReportView - Display and share clinical reports
struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Period Picker
                periodPickerSection
                
                Divider()
                
                // Content Area
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if viewModel.hasReport {
                    reportContentView
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Clinical Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.hasReport {
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(
                            item: viewModel.reportText,
                            subject: Text("AF Clinical Report"),
                            message: Text("My AF Clinical Summary")
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task {
                // Auto-generate report on appear
                await viewModel.generateReport()
            }
        }
    }
    
    // MARK: - View Components
    
    private var periodPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Period")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Picker("Period", selection: $viewModel.selectedPeriod) {
                Text("Month").tag(TimePeriod.month)
                Text("6 Months").tag(TimePeriod.sixMonths)
                Text("1 Year").tag(TimePeriod.oneYear)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedPeriod) { _, _ in
                Task {
                    await viewModel.generateReport()
                }
            }
            
            Text(viewModel.periodDateRangeLabel)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Generating Report...")
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task {
                    await viewModel.generateReport()
                }
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
    }
    
    private var reportContentView: some View {
        ScrollView {
            Text(viewModel.reportText)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Report Generated")
                .font(.headline)
            
            Text("Tap the button below to generate your clinical summary")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await viewModel.generateReport()
                }
            } label: {
                Label("Generate Report", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
}

#Preview {
    ReportView()
}
