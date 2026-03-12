import SwiftUI
import SwiftData
import Charts

/// AnalysisView - Main view for displaying symptom-AF correlation analysis
struct AnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AnalysisViewModel()
    @State private var selectedTab: AnalysisTab = .symptoms
    
    enum AnalysisTab: String, CaseIterable {
        case symptoms = "Symptoms"
        case triggers = "Triggers"
        case heartRate = "Heart Rate"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else {
                    analysisContent
                }
            }
            .navigationTitle("Analysis")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    refreshButton
                }
            }
        }
        .task {
            viewModel.configure(modelContext: modelContext)
            await viewModel.loadAnalysis()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView("Analyzing...")
                .font(.headline)
            Text("Processing your data")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task {
                    await viewModel.loadAnalysis()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private var analysisContent: some View {
        VStack(spacing: 20) {
            // Tab Picker
            Picker("Analysis Type", selection: $selectedTab) {
                ForEach(AnalysisTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Tab Content
            switch selectedTab {
            case .symptoms:
                symptomsTab
            case .triggers:
                triggersTab
            case .heartRate:
                heartRateTab
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Symptoms Tab
    
    private var symptomsTab: some View {
        VStack(spacing: 16) {
            // Correlation Summary
            if let correlation = viewModel.correlationResult {
                correlationCard(correlation)
            }
            
            // Symptom Breakdown
            if !viewModel.symptomBreakdown.isEmpty {
                symptomBreakdownCard
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func correlationCard(_ correlation: CorrelationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Symptom Correlation", systemImage: "waveform.path.ecg")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(correlation.symptomsWithAf)")
                        .font(.title.bold())
                        .foregroundStyle(.red)
                    Text("With AF")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text("\(correlation.symptomsWithoutAf)")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("Without AF")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text(String(format: "%.0f%%", correlation.afCooccurrenceRate * 100))
                        .font(.title.bold())
                        .foregroundStyle(Color.accentColor)
                    Text("Cooccurrence")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var symptomBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Symptom Breakdown", systemImage: "list.bullet")
                .font(.headline)
            
            ForEach(viewModel.symptomBreakdown) { symptom in
                if symptom.totalOccurrences > 0 {
                    HStack {
                        Text(symptom.symptomType.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("\(symptom.occurrencesWithAf) AF")
                                .font(.caption)
                                .foregroundStyle(.red)
                            
                            Text("\(symptom.occurrencesWithoutAf) normal")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Triggers Tab
    
    private var triggersTab: some View {
        VStack(spacing: 16) {
            if !viewModel.triggerBreakdown.isEmpty {
                triggerBreakdownCard
            } else {
                emptyStateView(
                    icon: "bolt.fill",
                    title: "No Triggers Logged",
                    message: "Log triggers to see correlation with AF episodes"
                )
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var triggerBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Trigger Correlation", systemImage: "bolt.fill")
                .font(.headline)
            
            ForEach(viewModel.triggerBreakdown) { trigger in
                if trigger.totalOccurrences > 0 {
                    HStack {
                        Text(trigger.triggerType.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("\(trigger.occurrencesWithAf) AF")
                                .font(.caption)
                                .foregroundStyle(.red)
                            
                            Text("\(trigger.occurrencesWithoutAf) normal")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Heart Rate Tab
    
    private var heartRateTab: some View {
        VStack(spacing: 16) {
            if let hr = viewModel.hrAnalysis {
                heartRateCard(hr)
            } else {
                emptyStateView(
                    icon: "heart.fill",
                    title: "No Heart Rate Data",
                    message: "Heart rate data will appear when episodes are detected"
                )
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func heartRateCard(_ hr: EpisodeHeartRateAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Heart Rate During Episodes", systemImage: "heart.fill")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text(String(format: "%.0f", hr.averageHeartRate))
                        .font(.title.bold())
                        .foregroundStyle(.orange)
                    Text("Avg BPM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text(String(format: "%.0f", hr.peakHeartRate))
                        .font(.title.bold())
                        .foregroundStyle(.red)
                    Text("Peak BPM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text("\(hr.totalEpisodesAnalyzed)")
                        .font(.title.bold())
                        .foregroundStyle(Color.accentColor)
                    Text("Episodes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            
            if hr.hasUnusuallyHighHR {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    Text("\(hr.episodesWithHighHR) episode(s) with unusually high heart rate (>150 BPM)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Empty State
    
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Toolbar
    
    private var refreshButton: some View {
        Button {
            Task {
                await viewModel.loadAnalysis()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isLoading)
    }
}

// MARK: - Preview

#Preview {
    AnalysisView()
        .modelContainer(for: [SymptomLog.self, TriggerLog.self])
}
