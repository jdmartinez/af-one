import SwiftUI
import Charts

@MainActor
@Observable
final class OverviewViewModel {
    var trend: TrendDirection = .stable
    var weeklyData: [DayRhythm] = []
    var pattern: PatternInsight = .noPattern
    var isLoading = false

    enum TrendDirection: String {
        case improving = "Improving"
        case stable = "Stable"
        case worsening = "Worsening"

        var icon: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .stable: return "arrow.right"
            case .worsening: return "arrow.down.right"
            }
        }

        var color: Color {
            switch self {
            case .improving: return .afOne.rhythmSinusal
            case .stable: return .yellow
            case .worsening: return .afOne.rhythmAF
            }
        }
    }

    struct DayRhythm: Identifiable {
        let id = UUID()
        let date: Date
        let hasEpisodes: Bool
        let episodeCount: Int
    }

    enum PatternInsight: String {
        case noPattern = "No clear pattern yet - keep tracking"
        case nocturnal = "Episodes often occur during sleep"
        case clustered = "Episodes tend to cluster"
        case activityRelated = "Episodes may be activity-related"
    }

    func loadData() async {
        isLoading = true

        let calendar = Calendar.current
        weeklyData = (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let hasEpisodes = daysAgo == 0 || daysAgo == 1 || daysAgo == 3
            return DayRhythm(
                date: date,
                hasEpisodes: hasEpisodes,
                episodeCount: hasEpisodes ? Int.random(in: 1...3) : 0
            )
        }

        let recentEpisodes = weeklyData.filter { $0.hasEpisodes }.count
        if recentEpisodes <= 1 {
            trend = .improving
        } else if recentEpisodes >= 4 {
            trend = .worsening
        } else {
            trend = .stable
        }

        pattern = .noPattern

        isLoading = false
    }
}

struct OverviewView: View {
    @State private var viewModel = OverviewViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    trendCard
                    weeklySummaryCard
                    patternCard
                }
                .padding()
            }
            .navigationTitle("Overview")
        }
        .task {
            await viewModel.loadData()
        }
    }

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your heart rhythm pattern")
                .font(.headline)

            HStack {
                Image(systemName: viewModel.trend.icon)
                    .font(.title)
                    .foregroundStyle(viewModel.trend.color)

                Text(viewModel.trend.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var weeklySummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Summary")
                .font(.headline)

            Chart(viewModel.weeklyData) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Episodes", day.episodeCount)
                )
                .foregroundStyle(day.hasEpisodes ? Color.afOne.rhythmAF : Color.afOne.rhythmSinusal)
                .cornerRadius(4)
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var patternCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pattern Insight")
                .font(.headline)

            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)

                Text(viewModel.pattern.rawValue)
                    .font(.body)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
