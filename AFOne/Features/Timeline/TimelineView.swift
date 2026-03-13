import SwiftUI
import SwiftData
import Charts

@MainActor
@Observable
final class TimelineViewModel {
    var selectedPeriod: TimePeriod = .week
    var days: [DayData] = []
    var selectedDay: DayData?
    var hourlyData: [HourlyRhythm] = []
    var isLoading = false

    enum TimePeriod: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
    }

    struct DayData: Identifiable {
        let id = UUID()
        let date: Date
        let dominantRhythm: RhythmState
        let hasData: Bool
    }

    struct HourlyRhythm: Identifiable {
        let id = UUID()
        let hour: Int
        let rhythm: RhythmState
    }

    enum RhythmState {
        case normal
        case af
        case unknown
    }

    func loadData() async {
        isLoading = true

        let calendar = Calendar.current
        let dayCount = selectedPeriod == .week ? 7 : 30
        let startDate = calendar.date(byAdding: .day, value: -dayCount, to: Date())!

        do {
            let burdens = try await HealthKitService.shared.fetchAfBurden(from: startDate, to: Date())
            let episodes = try await HealthKitService.shared.fetchEpisodes(from: startDate, to: Date())
            
            days = (0..<dayCount).reversed().map { daysAgo in
                let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
                let dayStart = calendar.startOfDay(for: date)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
                
                let dayBurden = burdens.first { $0.date >= dayStart && $0.date < dayEnd }
                let dayEpisodes = episodes.filter { $0.startDate >= dayStart && $0.startDate < dayEnd }
                
                let hasData = dayBurden != nil || !dayEpisodes.isEmpty
                let rhythm: RhythmState
                
                if let burden = dayBurden, burden.percentage > 0 {
                    rhythm = .af
                } else if !dayEpisodes.isEmpty {
                    rhythm = .af
                } else if hasData {
                    rhythm = .normal
                } else {
                    rhythm = .unknown
                }
                
                return DayData(date: date, dominantRhythm: rhythm, hasData: hasData)
            }
        } catch {
            days = (0..<dayCount).reversed().map { daysAgo in
                let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
                return DayData(date: date, dominantRhythm: .unknown, hasData: false)
            }
        }

        isLoading = false
    }

    func selectDay(_ day: DayData) {
        selectedDay = day
        
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day.date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        Task {
            do {
                let episodes = try await HealthKitService.shared.fetchEpisodes(from: dayStart, to: dayEnd)
                let heartRates = try await HealthKitService.shared.fetchHeartRateSamples(from: dayStart, to: dayEnd)
                
                await MainActor.run {
                    if !day.hasData || (episodes.isEmpty && heartRates.isEmpty) {
                        hourlyData = (0..<24).map { hour in
                            HourlyRhythm(hour: hour, rhythm: .unknown)
                        }
                    } else {
                        hourlyData = (0..<24).map { hour in
                            let hourStart = calendar.date(byAdding: .hour, value: hour, to: dayStart)!
                            let hourEnd = calendar.date(byAdding: .hour, value: hour + 1, to: dayStart)!
                            
                            let hourEpisodes = episodes.filter { ep in
                                ep.startDate >= hourStart && ep.startDate < hourEnd
                            }
                            
                            let rhythm: RhythmState = hourEpisodes.isEmpty ? .normal : .af
                            return HourlyRhythm(hour: hour, rhythm: rhythm)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    hourlyData = (0..<24).map { hour in
                        HourlyRhythm(hour: hour, rhythm: .unknown)
                    }
                }
            }
        }
    }
}

struct TimelineView: View {
    @State private var viewModel = TimelineViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SymptomLog.timestamp, order: .reverse) private var symptoms: [SymptomLog]
    @Query(sort: \TriggerLog.timestamp, order: .reverse) private var triggers: [TriggerLog]
    
    private var recentSymptoms: [SymptomLog] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return symptoms.filter { $0.timestamp >= weekAgo }
    }
    
    private var recentTriggers: [TriggerLog] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return triggers.filter { $0.timestamp >= weekAgo }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.days.allSatisfy({ !$0.hasData }) {
                    emptyStateView
                } else {
                    timelineContent
                }
            }
            .navigationTitle("Timeline")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    legendView
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading timeline...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Rhythm Data Available")
                .font(.headline)
            
            Text("Keep your Apple Watch on to monitor your heart rhythm over time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private var timelineContent: some View {
        VStack(spacing: 0) {
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(TimelineViewModel.TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: viewModel.selectedPeriod) { _, _ in
                Task {
                    await viewModel.loadData()
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.days) { day in
                        DayBlockView(
                            day: day,
                            isSelected: viewModel.selectedDay?.id == day.id
                        )
                        .onTapGesture {
                            viewModel.selectDay(day)
                        }
                    }
                }
                .padding(.horizontal)
            }

            if viewModel.selectedDay != nil {
                Divider()
                    .padding(.top)

                hourlyBreakdownView
            }

            Spacer()
        }
    }

    private var hourlyBreakdownView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let selectedDay = viewModel.selectedDay {
                Text(selectedDay.date.formatted(date: .complete, time: .omitted))
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(viewModel.hourlyData) { hour in
                        BarMark(
                            x: .value("Hour", hour.hour),
                            y: .value("Rhythm", rhythmValue(hour.rhythm))
                        )
                        .foregroundStyle(rhythmColor(hour.rhythm))
                        .cornerRadius(2)
                    }
                }
                .frame(height: 100)
            }
        }
        .padding(.top)
    }

    private var legendView: some View {
        HStack(spacing: 12) {
            LegendItem(color: .green, label: "Normal")
            LegendItem(color: .red, label: "AF")
            LegendItem(color: .gray, label: "Unknown")
            if !recentSymptoms.isEmpty {
                Divider()
                    .frame(height: 12)
                LegendItem(color: .red, label: "Symptom")
            }
        }
    }

    private func rhythmValue(_ rhythm: TimelineViewModel.RhythmState) -> Int {
        switch rhythm {
        case .normal: return 1
        case .af: return 2
        case .unknown: return 0
        }
    }

    private func rhythmColor(_ rhythm: TimelineViewModel.RhythmState) -> Color {
        switch rhythm {
        case .normal: return .green
        case .af: return .red
        case .unknown: return .gray
        }
    }
}

struct DayBlockView: View {
    let day: TimelineViewModel.DayData
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(day.date, format: .dateTime.weekday(.narrow))
                .font(.caption)
                .fontWeight(.medium)

            Text(day.date, format: .dateTime.day())
                .font(.headline)

            Circle()
                .fill(rhythmColor)
                .frame(width: 30, height: 30)
        }
        .frame(width: 60, height: 80)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }

    private var rhythmColor: Color {
        guard day.hasData else { return .gray.opacity(0.3) }
        switch day.dominantRhythm {
        case .normal: return .green
        case .af: return .red
        case .unknown: return .gray
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
        }
    }
}
