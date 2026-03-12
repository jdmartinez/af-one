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

        days = (0..<dayCount).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let hasData = daysAgo <= 7
            let rhythm: RhythmState = hasData ? (Bool.random() ? .normal : .af) : .unknown
            return DayData(date: date, dominantRhythm: rhythm, hasData: hasData)
        }

        isLoading = false
    }

    func selectDay(_ day: DayData) {
        selectedDay = day

        hourlyData = (0..<24).map { hour in
            let rhythm: RhythmState = [.normal, .af, .unknown].randomElement()!
            return HourlyRhythm(hour: hour, rhythm: rhythm)
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
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(TimelineViewModel.TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

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
