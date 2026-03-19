import Foundation
import SwiftUI

// MARK: - Supporting Types

/// RhythmPeriod — period selection (RHYM-02), mirrors BurdenDetailView pattern
enum RhythmPeriod: String, CaseIterable, Identifiable {
    case day = "Día"
    case week = "Semana"
    case month = "Mes"

    var id: String { rawValue }

    var dayCount: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        }
    }
}

/// RhythmScenario — day selection scenarios (RHYM-01)
enum RhythmScenario: String, CaseIterable, Identifiable {
    case today = "Hoy"
    case yesterday = "Ayer"
    case highBurden = "Mayor carga"

    var id: String { rawValue }

    var daysOffset: Int {
        switch self {
        case .today: return 0
        case .yesterday: return 1
        case .highBurden: return 0  // Determined by analysis
        }
    }
}

/// CircadianBlock — 3-hour block for AF onset frequency histogram (RHYM-08)
struct CircadianBlock: Identifiable {
    let id = UUID()
    let blockIndex: Int           // 0-7
    let hourRange: ClosedRange<Int>
    let afOnsetCount: Int
    let totalEpisodes: Int

    var afFrequency: Double {
        guard totalEpisodes > 0 else { return 0 }
        return Double(afOnsetCount) / Double(totalEpisodes)
    }

    var hourRangeText: String {
        String(format: "%02d:00-%02d:00", hourRange.lowerBound, hourRange.upperBound + 1)
    }

    static func buildBlocks() -> [CircadianBlock] {
        (0..<8).map { index in
            CircadianBlock(
                blockIndex: index,
                hourRange: (index * 3)...(index * 3 + 2),
                afOnsetCount: 0,
                totalEpisodes: 0
            )
        }
    }
}

/// StatsSummary — computed stats for the stats row (RHYM-05, RHYM-07)
struct StatsSummary {
    let srPercentage: Double
    let afPercentage: Double
    let noDataPercentage: Double
    let episodeCount: Int
    let totalHours: Int
    let hoursWithData: Int

    var coveragePercentage: Double {
        guard totalHours > 0 else { return 0 }
        return Double(hoursWithData) / Double(totalHours) * 100
    }

    static let empty = StatsSummary(
        srPercentage: 0, afPercentage: 0, noDataPercentage: 100,
        episodeCount: 0, totalHours: 24, hoursWithData: 0
    )
}

/// EpisodeDetailItem — per-episode item for the list (RHYM-06)
struct EpisodeDetailItem: Identifiable {
    let id: UUID
    let startDate: Date
    let duration: TimeInterval
    let meanHR: Int
    let peakHR: Int
    let minSpO2: Int?
    let hasECG: Bool
    let insufficientData: Bool  // <3 HR samples during episode

    var durationFormatted: String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}

// MARK: - ViewModel

/// RhythmMapDetailViewModel — manages rhythm map detail data and analysis (RHYM-01 through RHYM-08)
@MainActor
@Observable
final class RhythmMapDetailViewModel {
    // MARK: - Selection State (RHYM-01, RHYM-02)
    var selectedPeriod: RhythmPeriod = .day
    var selectedScenario: RhythmScenario = .today

    // MARK: - Computed Data
    var hourlyData: [HourlyRhythmData] = []
    var hrTrendData: [HeartRateTrendPoint] = []
    var stats: StatsSummary = .empty
    var circadianBlocks: [CircadianBlock] = CircadianBlock.buildBlocks()
    var episodeItems: [EpisodeDetailItem] = []
    var highBurdenDate: Date?

    // MARK: - UI State
    var isLoading = false
    var selectedHour: Int?
    var showHourDetail = false

    // MARK: - Supporting Types
    struct HeartRateTrendPoint: Identifiable {
        let id = UUID()
        let hour: Int
        let averageHR: Int?
    }

    // MARK: - Computed Properties
    private var analysisStartDate: Date {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            let offset = selectedScenario.daysOffset
            return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -offset, to: Date())!)
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: Date())!
        case .month:
            return calendar.date(byAdding: .day, value: -30, to: Date())!
        }
    }

    private var analysisEndDate: Date {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            let offset = selectedScenario.daysOffset
            let dayStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -offset, to: Date())!)
            return calendar.date(byAdding: .day, value: 1, to: dayStart)!
        default:
            return Date()
        }
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true

        let calendar = Calendar.current
        let startDate = analysisStartDate
        let endDate = analysisEndDate

        do {
            async let hrSamples = try HealthKitService.shared.fetchHeartRateSamples(from: startDate, to: endDate)
            async let episodes = try HealthKitService.shared.fetchEpisodes(from: startDate, to: endDate)

            let (hrReadings, rhythmEpisodes) = try await (hrSamples, episodes)

            // Compute hourly rhythm data with sample counts
            hourlyData = computeHourlyData(hrReadings: hrReadings, episodes: rhythmEpisodes)

            // Compute HR trend line data
            hrTrendData = computeHRTrend(hrReadings: hrReadings)

            // Compute stats
            stats = computeStats(hourlyData: hourlyData, episodeCount: rhythmEpisodes.count)

            // Compute circadian pattern
            circadianBlocks = computeCircadianBlocks(episodes: rhythmEpisodes)

            // Find high-burden day for scenario button
            highBurdenDate = findHighBurdenDay(hrReadings: hrReadings, episodes: rhythmEpisodes)

            // Compute episode detail items
            episodeItems = computeEpisodeItems(episodes: rhythmEpisodes, hrReadings: hrReadings)
        } catch {
            // Fallback to empty state
            hourlyData = (0..<24).map {
                HourlyRhythmData(hour: $0, rhythmClassification: .noData, sampleCount: 0, averageHeartRate: nil)
            }
            hrTrendData = []
            stats = .empty
            circadianBlocks = CircadianBlock.buildBlocks()
            episodeItems = []
        }

        isLoading = false
    }

    // MARK: - Hourly Data Computation (RHYM-03, RHYM-04)

    private func computeHourlyData(
        hrReadings: [HeartRateReading],
        episodes: [RhythmEpisode]
    ) -> [HourlyRhythmData] {
        let calendar = Calendar.current

        return (0..<24).map { hour in
            let hourStart = calendar.date(byAdding: .hour, value: hour, to: analysisStartDate)!
            let hourEnd = calendar.date(byAdding: .hour, value: hour + 1, to: analysisStartDate)!

            // Get HR readings in this hour
            let hourReadings = hrReadings.filter { reading in
                reading.timestamp >= hourStart && reading.timestamp < hourEnd
            }

            let sampleCount = hourReadings.count

            // Determine rhythm classification
            let classification: RhythmClassification
            if sampleCount == 0 {
                classification = .noData
            } else {
                // Check if any AF episodes overlap with this hour
                let hasAF = episodes.contains { episode in
                    episode.startDate < hourEnd && episode.endDate > hourStart && episode.rhythmType == .af
                }
                classification = hasAF ? .atrialFibrillation : .sinusRhythm
            }

            // Compute average HR
            let avgHR: Int? = if hourReadings.isEmpty {
                nil
            } else {
                hourReadings.map { $0.bpm }.reduce(0, +) / hourReadings.count
            }

            return HourlyRhythmData(
                hour: hour,
                rhythmClassification: classification,
                sampleCount: sampleCount,
                averageHeartRate: avgHR
            )
        }
    }

    // MARK: - HR Trend Computation (RHYM-03)

    private func computeHRTrend(hrReadings: [HeartRateReading]) -> [HeartRateTrendPoint] {
        let calendar = Calendar.current

        return (0..<24).map { hour in
            let hourStart = calendar.date(byAdding: .hour, value: hour, to: analysisStartDate)!
            let hourEnd = calendar.date(byAdding: .hour, value: hour + 1, to: analysisStartDate)!

            let hourReadings = hrReadings.filter { reading in
                reading.timestamp >= hourStart && reading.timestamp < hourEnd
            }

            let avgHR: Int? = if hourReadings.isEmpty {
                nil
            } else {
                hourReadings.map { $0.bpm }.reduce(0, +) / hourReadings.count
            }

            return HeartRateTrendPoint(hour: hour, averageHR: avgHR)
        }
    }

    // MARK: - Stats Computation (RHYM-05)

    private func computeStats(hourlyData: [HourlyRhythmData], episodeCount: Int) -> StatsSummary {
        let totalHours = hourlyData.count
        let hoursWithData = hourlyData.filter { $0.rhythmClassification != .noData }.count
        let afHours = hourlyData.filter { $0.rhythmClassification == .atrialFibrillation }.count
        let srHours = hourlyData.filter { $0.rhythmClassification == .sinusRhythm }.count
        let noDataHours = hourlyData.filter { $0.rhythmClassification == .noData }.count

        let srPct = totalHours > 0 ? Double(srHours) / Double(totalHours) * 100 : 0
        let afPct = totalHours > 0 ? Double(afHours) / Double(totalHours) * 100 : 0
        let noDataPct = totalHours > 0 ? Double(noDataHours) / Double(totalHours) * 100 : 100

        return StatsSummary(
            srPercentage: srPct,
            afPercentage: afPct,
            noDataPercentage: noDataPct,
            episodeCount: episodeCount,
            totalHours: totalHours,
            hoursWithData: hoursWithData
        )
    }

    // MARK: - Circadian Pattern Computation (RHYM-08)

    private func computeCircadianBlocks(episodes: [RhythmEpisode]) -> [CircadianBlock] {
        let calendar = Calendar.current

        // Count AF onsets per 3-hour block across all episodes
        var blockOnsets = [Int: Int]()  // blockIndex -> count
        let totalEpisodes = episodes.count

        for episode in episodes {
            let hour = calendar.component(.hour, from: episode.startDate)
            let blockIndex = hour / 3
            blockOnsets[blockIndex, default: 0] += 1
        }

        return CircadianBlock.buildBlocks().map { block in
            CircadianBlock(
                blockIndex: block.blockIndex,
                hourRange: block.hourRange,
                afOnsetCount: blockOnsets[block.blockIndex] ?? 0,
                totalEpisodes: totalEpisodes
            )
        }
    }

    // MARK: - High-Burden Day Detection (RHYM-01)

    private func findHighBurdenDay(
        hrReadings: [HeartRateReading],
        episodes: [RhythmEpisode]
    ) -> Date? {
        let calendar = Calendar.current

        // Look at last 14 days to find highest burden
        var dailyBurden: [(date: Date, burden: Double)] = []

        for daysAgo in 0..<14 {
            let dayDate = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let dayStart = calendar.startOfDay(for: dayDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let dayEpisodes = episodes.filter { ep in
                ep.startDate >= dayStart && ep.startDate < dayEnd
            }

            if !dayEpisodes.isEmpty {
                let totalDuration = dayEpisodes.reduce(0.0) { $0 + $1.duration }
                let burden = totalDuration / (24 * 60 * 60) * 100  // percentage
                dailyBurden.append((date: dayDate, burden: burden))
            }
        }

        // Return date with highest burden
        return dailyBurden.max(by: { $0.burden < $1.burden })?.date
    }

    // MARK: - Episode Items (RHYM-06)

    private func computeEpisodeItems(
        episodes: [RhythmEpisode],
        hrReadings: [HeartRateReading]
    ) -> [EpisodeDetailItem] {
        return episodes.map { episode in
            // Get HR readings during episode
            let episodeHR = hrReadings.filter { reading in
                reading.timestamp >= episode.startDate && reading.timestamp <= episode.endDate
            }

            let insufficientData = episodeHR.count < 3

            // Estimate SpO2 (HealthKit doesn't provide this — mark as nil for now)
            let minSpO2: Int? = nil

            // ECG availability check (placeholder — would check ECG results)
            let hasECG = false

            return EpisodeDetailItem(
                id: episode.id,
                startDate: episode.startDate,
                duration: episode.duration,
                meanHR: episode.averageHR,
                peakHR: episode.peakHR,
                minSpO2: minSpO2,
                hasECG: hasECG,
                insufficientData: insufficientData
            )
        }
    }

    // MARK: - Hour Detail

    func selectHour(_ hour: Int) {
        selectedHour = hour
        showHourDetail = true
    }
}
