import SwiftUI

@MainActor
@Observable
final class DashboardViewModel {
    var currentStatus: RhythmStatus = .unknown
    var recentEpisodes: [RhythmEpisode] = []
    var afBurden: Double = 0.0
    var episodeCount: Int = 0
    var averageHR: Int = 0
    var isLoading = false
    var lastUpdated: Date = Date()
    var trend: TrendDirection = .stable

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
    }

    func loadData() async {
        isLoading = true

        currentStatus = await HealthKitService.shared.fetchCurrentRhythmStatus()

        let now = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!

        do {
            let burdens = try await HealthKitService.shared.fetchAfBurden(from: weekAgo, to: now)
            if let latestBurden = burdens.first {
                afBurden = latestBurden.percentage
            }

            let episodes = try await HealthKitService.shared.fetchEpisodes(from: weekAgo, to: now)
            recentEpisodes = Array(episodes.prefix(3))
            episodeCount = episodes.count

            let readings = try await HealthKitService.shared.fetchHeartRateSamples(from: weekAgo, to: now)
            if !readings.isEmpty {
                let total = readings.reduce(0) { $0 + $1.bpm }
                averageHR = total / readings.count
            }

            calculateTrend()
        } catch {
            // Use sample data on error
            recentEpisodes = [
                RhythmEpisode(id: UUID(), startDate: Date().addingTimeInterval(-7200), endDate: Date().addingTimeInterval(-3600), averageHR: 125, peakHR: 145, rhythmType: .af),
                RhythmEpisode(id: UUID(), startDate: Date().addingTimeInterval(-86400), endDate: Date().addingTimeInterval(-82800), averageHR: 110, peakHR: 132, rhythmType: .af),
            ]
            episodeCount = 2
            afBurden = 3.5
            averageHR = 72
        }

        lastUpdated = Date()
        isLoading = false
    }

    private func calculateTrend() {
        // Simplified trend calculation
        if afBurden < 1 {
            trend = .improving
        } else if afBurden > 10 {
            trend = .worsening
        } else {
            trend = .stable
        }
    }
}
