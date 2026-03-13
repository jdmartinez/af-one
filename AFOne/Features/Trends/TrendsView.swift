import SwiftUI
import Charts

/// TrendsView - Long-term trend visualization with period selection
struct TrendsView: View {
    @StateObject private var viewModel = TrendsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        loadingView
                    } else if let error = viewModel.errorMessage {
                        errorView(error)
                    } else {
                        periodPicker
                        periodHeader
                        trendCards
                        burdenChart
                    }
                }
                .padding()
            }
            .navigationTitle("Trends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    refreshButton
                }
            }
        }
        .task {
            await viewModel.loadTrends()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView("Loading trends...")
                .font(.headline)
            Text("Analyzing your data")
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
                    await viewModel.loadTrends()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private var periodPicker: some View {
        Picker("Period", selection: $viewModel.selectedPeriod) {
            ForEach(TimePeriod.allCases) { period in
                Text(period.shortName).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            Task {
                await viewModel.loadTrends()
            }
        }
    }
    
    private var periodHeader: some View {
        Text(viewModel.periodDateRangeLabel)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    private var trendCards: some View {
        VStack(spacing: 16) {
            burdenTrendCard
            episodeTrendCard
        }
    }
    
    private var burdenTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AF Burden Trend", systemImage: "heart.fill")
                .font(.headline)
            
            if let trend = viewModel.burdenTrend {
                HStack {
                    trendIndicator(direction: trend.direction)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trend.displayText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(trendColor(for: trend.direction))
                        
                        Text("vs previous period")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            } else {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var episodeTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Episode Frequency Trend", systemImage: "waveform.path.ecg")
                .font(.headline)
            
            if let trend = viewModel.episodeTrend {
                HStack {
                    trendIndicator(direction: trend.direction)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trend.displayText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(trendColor(for: trend.direction))
                        
                        Text("vs previous period")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            } else {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func trendIndicator(direction: TrendDirection) -> some View {
        Text(direction.rawValue)
            .font(.system(size: 40))
            .foregroundStyle(trendColor(for: direction))
    }
    
    private func trendColor(for direction: TrendDirection) -> Color {
        switch direction {
        case .increasing:
            return .red
        case .decreasing:
            return .green
        case .stable:
            return .yellow
        }
    }
    
    private var burdenChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AF Burden Over Time", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
            
            if viewModel.burdenData.isEmpty {
                emptyChartState
            } else {
                Chart(viewModel.burdenData) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Burden", dataPoint.percentage)
                    )
                    .foregroundStyle(Color.accentColor)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Burden", dataPoint.percentage)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue))%")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let dateValue = value.as(Date.self) {
                                Text(formatAxisDate(dateValue))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var emptyChartState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No Data Available")
                .font(.headline)
            Text("Start logging episodes to see your trends")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private func formatAxisDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        switch viewModel.selectedPeriod {
        case .day:
            formatter.dateFormat = "h a"
        case .week:
            formatter.dateFormat = "EEE"
        case .month:
            formatter.dateFormat = "MMM d"
        case .sixMonths:
            formatter.dateFormat = "MMM d"
        case .oneYear:
            formatter.dateFormat = "MMM"
        }
        
        return formatter.string(from: date)
    }
    
    private var refreshButton: some View {
        Button {
            Task {
                await viewModel.loadTrends()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isLoading)
    }
}

// MARK: - Preview

#Preview {
    TrendsView()
}
